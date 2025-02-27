# `4-counter`

<br>

This example defines a custom middleware, `count_requests`, and exposes the
request count at
[http://localhost:8080/dashboard](http://localhost:8080/dashboard):

```ocaml
let count = ref 0

let count_requests inner_handler request =
  count := !count + 1;
  inner_handler request

let () =
  Dream.run
  @@ Dream.logger
  @@ count_requests
  @@ Dream.router [
    Dream.get "/dashboard" (fun _ ->
      Dream.respond (Printf.sprintf "Saw %i request(s)!" !count));
  ]
  @@ Dream.not_found
```
<pre><code><b>$ dune exec --root . ./counter.exe</b></code></pre>

<br>

As you can see, defining middlewares in Dream is completely trivial! They are
just functions that take an `inner_handler` as a parameter, and wrap it. They
act like handlers themselves, which means they usually also take a `request`.

This example's middleware only does something *before* calling the
`inner_handler`. The next example, [**`5-echo`**](../5-echo/#files), already
shows a bit of [Lwt](https://github.com/ocsigen/lwt#readme), the promise library
used by Dream, but [**`a-promise`**](../a-promise/#files) introduces
Lwt more fully. [**`a-promise`**](../a-promise/#files) uses Lwt to await a
response from `inner_handler`, and do something *after*.

<br>

Advanced example [**`w-globals`**](../w-globals/#files) shows how to replace
global state like `count` by state scoped to the application. This is useful if
you are writing middleware to publish in a library. It's fine to use a global
`ref` in private code!

<br>

**Next steps:**

- [**`5-echo`**](../5-echo/#files) responds to `POST` requests and reads their
  bodies.
- [**`6-template`**](../6-template/#files) embeds HTML in OCaml... or OCaml in
  HTML!

<br>

[Up to the tutorial index](../#readme)
