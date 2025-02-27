(* This file is part of Dream, released under the MIT license. See
   LICENSE.md for details, or visit https://github.com/aantron/dream.

   Copyright 2021 Anton Bachin *)



module Dream = Dream__pure.Inmost
module Session = Dream__middleware.Session



let (|>?) =
  Option.bind

(* TODO Expose later, probably as a string -> unit promsie function. *)
(* let create_table () =
  let query =
    Caqti_request.exec Caqti_type.unit {|
      CREATE TABLE dream_session (
        key TEXT NOT NULL PRIMARY KEY,
        id TEXT NOT NULL,
        expires_at REAL NOT NULL,
        payload TEXT NOT NULL
      )
    |}
  in
  ... *)

(* TODO Strongly recommend HTTPS. *)
(* TODO Session id and HTTP->HTTPS redirects. *)
(* TODO Rename session key to id, and id to something else. *)
(* TODO https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html#session-id-length *)
(* TODO Can probably reduce key to 18 bytes. *)
(* TODO Recommend BeeKeeper in example. *)
module type DB = Caqti_lwt.CONNECTION

module R = Caqti_request
module T = Caqti_type

let serialize_payload payload =
  payload
  |> List.map (fun (name, value) -> name, `String value)
  |> fun assoc -> `Assoc assoc
  |> Yojson.Basic.to_string

let insert =
  let query =
    R.exec T.(tup4 string string float string) {|
      INSERT INTO dream_session (key, id, expires_at, payload)
      VALUES ($1, $2, $3, $4)
    |} in

  fun (module Db : DB) (session : Session.session) ->
    let payload = serialize_payload session.payload in
    let%lwt result =
      Db.exec query (session.key, session.id, session.expires_at, payload) in
    Caqti_lwt.or_fail result

let find_opt =
  let query =
    R.find_opt T.string T.(tup3 string float string)
      "SELECT id, expires_at, payload FROM dream_session WHERE key = $1" in

  fun (module Db : DB) key ->
    let%lwt result = Db.find_opt query key in
    match%lwt Caqti_lwt.or_fail result with
    | None -> Lwt.return_none
    | Some (id, expires_at, payload) ->
      (* TODO Mind exceptions! *)
      let payload =
        Yojson.Basic.from_string payload
        |> function
          | `Assoc payload ->
            payload |> List.map (function
              | name, `String value -> name, value
              | _ -> failwith "Bad payload")
          | _ -> failwith "Bad payload"
      in
      Lwt.return_some Session.{
        key;
        id;
        expires_at;
        payload;
      }

let refresh =
  let query =
    R.exec T.(tup2 float string)
      "UPDATE dream_session SET expires_at = $1 WHERE key = $2" in

  fun (module Db : DB) (session : Session.session) ->
    let%lwt result = Db.exec query (session.expires_at, session.key) in
    Caqti_lwt.or_fail result

let update =
  let query =
    R.exec T.(tup2 string string)
      "UPDATE dream_session SET payload = $1 WHERE key = $2" in

  fun (module Db : DB) (session : Session.session) ->
    let payload = serialize_payload session.payload in
    let%lwt result = Db.exec query (payload, session.key) in
    Caqti_lwt.or_fail result

let remove =
  let query = R.exec T.string "DELETE FROM dream_session WHERE key = $1" in

  fun (module Db : DB) key ->
    let%lwt result = Db.exec query key in
    Caqti_lwt.or_fail result

(* TODO Session sharing is greatly complicated by the backing store; is it ok to
   just work with snapshots? All kinds of race conditions may be possible,
   unless there is a generation value or the like. *)
(* TODO This can be greatly addressed with a cache, which is desirable
   anyway. *)
(* TODO The in-memory sessions manager should actually be re-done in terms of
   the cache, just with no persistent backing store. *)

let rec create db expires_at attempt =
  let session = Session.{
    key = Dream__pure.Random.random 33 |> Dream__pure.Formats.to_base64url;
    id = Session.new_id ();
    expires_at;
    payload = [];
  } in
  (* Assume that any exception is a PRIMARY KEY collision (extremely unlikely)
     and try a couple more times. *)
  match%lwt insert db session with
  | exception Caqti_error.Exn _ when attempt <= 3 ->
    create db expires_at (attempt + 1)
  | () ->
    Lwt.return session

let set request (session : Session.session) name value =
  session.payload
  |> List.remove_assoc name
  |> fun dictionary -> (name, value)::dictionary
  |> fun dictionary -> session.payload <- dictionary;
  request |> Sql.sql (fun db -> update db session)

let invalidate request lifetime operations (session : Session.session ref) =
  request |> Sql.sql begin fun db ->
    let%lwt () = remove db !session.key in
    let%lwt new_session = create db (Unix.gettimeofday () +. lifetime) 1 in
    session := new_session;
    operations.Session.dirty <- true;
    Lwt.return_unit
  end

let operations request lifetime (session : Session.session ref) dirty =
  let rec operations = {
    Session.set = (fun name value -> set request !session name value);
    invalidate = (fun () -> invalidate request lifetime operations session);
    dirty;
  } in
  operations

let load lifetime request =
  request |> Sql.sql begin fun db ->
    let now = Unix.gettimeofday () in

    let%lwt valid_session =
      match Dream.cookie ~decrypt:false Session.session_cookie request with
      | None -> Lwt.return_none
      | Some key ->
        match%lwt find_opt db key with
        | None -> Lwt.return_none
        | Some session ->
          if session.expires_at > now then
            Lwt.return (Some session)
          else begin
            let%lwt () = remove db key in
            Lwt.return_none
          end
    in

    let%lwt dirty, session =
      match valid_session with
      | Some session ->
        if session.expires_at -. now > (lifetime /. 2.) then
          Lwt.return (false, session)
        else begin
          session.expires_at <- now +. lifetime;
          let%lwt () = refresh db session in
          Lwt.return (true, session)
        end
      | None ->
        let%lwt session = create db (now +. lifetime) 1 in
        Lwt.return (true, session)
    in

    let session = ref session in
    Lwt.return (operations request lifetime session dirty, session)
  end

let send (operations, session) request response =
  if not operations.Session.dirty then
    Lwt.return response
  else
    let max_age = !session.Session.expires_at -. Unix.gettimeofday () in
    Lwt.return
      (Dream.set_cookie
        Session.session_cookie
        !session.key
        request
        response
        ~encrypt:false
        ~max_age)

let back_end lifetime = {
  Session.load = load lifetime;
  send;
}

let middleware ?(lifetime = Session.two_weeks) =
  Session.middleware (back_end lifetime)
