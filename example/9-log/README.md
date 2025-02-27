# `9-log`

<br>

This app writes custom messages to Dream's log:

```ocaml
let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/"
      (fun request ->
        Dream.log "Sending greeting to %s!" (Dream.client request);
        Dream.respond "Good morning, world!");

    Dream.get "/fail"
      (fun _ ->
        Dream.warning (fun log -> log "Raising an exception!");
        raise (Failure "The web app failed!"));

  ]
  @@ Dream.not_found
```

<pre><code><b>$ dune exec --root . ./log.exe</b></code></pre>

<br>

If you visit [http://localhost:8080](http://localhost:8080) and then
[http://localhost:8080/fail](http://localhost:8080/fail), you will find these
messages in the log, between the other messages:

```
26.03.21 21:25:17.383                       REQ 1 Sending greeting to 127.0.0.1:64099!
26.03.21 21:25:19.464                  WARN REQ 2 Raising an exception!
```

As you can see, the functions take
[`Printf`-style format strings](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Printf.html),
so you can quickly print values of various types to the log.

<br>

`Dream.warning` is a bit strange. The reason it takes a callback, which waits
for a `log` argument, is because if the log threshold is higher than
`` `Warning``, the callback is never called, so the application doesn't spend
any time formatting a string that it will not print. This is the style of the
[Logs](https://erratique.ch/software/logs) library. Try inserting this code
right before `Dream.run` to see the message suppressed:

```ocaml
Dream.initialize_log ~level:`Error ();
```

<br>

You can create named sub-logs for different parts of your application with
`Dream.sub_log`:

```ocaml
let my_log =
  Dream.sub_log "my.log"

let () =
  sub_log.warning (fun log -> log "Hmmm...")
```

<br>

**Next steps:**

- In [**`a-promise`**](../a-promise/#files), we combine logging with the promise
  library Lwt to sketch out a custom logger.
- [**`b-session`**](../b-session/#files) finally returns web development proper
  with *session management*.

<br>

[Up to the tutorial index](../#readme)
