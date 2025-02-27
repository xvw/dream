# `3-router`

<br>

A *router* sends requests to different handlers, depending on their method and
path. In this example, we still serve `Good morning, world!` at our site root,
`/`. But, we have a different response for `GET` requests to `/echo/*`, and we
respond to everything else with `404 Not Found`:

```ocaml
let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/"
      (fun _ ->
        Dream.respond "Good morning, world!");

    Dream.get "/echo/:word"
      (fun request ->
        Dream.respond (Dream.param "word" request));

  ]
  @@ fun _ ->
    Dream.empty `Not_Found
```

<pre><code><b>$ dune exec --root . ./router.exe</b></code></pre>

<br>

This is also our first dynamic site! A request to `/echo/foo` gets the response
`foo`, and a request to `/echo/bar` gets `bar`! The syntax `:word` in a route
creates a path parameter, which can be read with `Dream.param`.

<!-- TODO hyperlink Dream.param to docsc, also Dream.logger. -->

The whole router is a middleware, just like `Dream.logger`. When none of the
routes match, the router passes the request to the next handler, which is right
beneath it. In this example, we just respond with `404 Not Found` when that
happens.

Except for the status code, the `404 Not Found` response is *completely* empty,
so it might not display well in your browser. In
[**`8-error-page`**](../8-error-page/#files), we will decorate all error
responses with an error template in one central location.

<br>

The router can do more than match simple routes:

- [**`f-static`**](../f-static/#files) forwards all requests with a certain
  prefix to a static file handler.
- [**`w-scope`**](../w-scope/#files) applies middlewares to groups of routes
  &mdash; but only when they match.
- [**`w-subsite`**](../w-subsite/#files) attaches a handler as a complete,
  nested sub-site, which might have its own router.

<br>

**Next steps:**

- [**`4-counter`**](../4-counter/#files) counts requests, and exposes a special
  route for getting the count.
- [**`5-echo`**](../5-echo/#files) is dynamic in another way: by reading the
  request body.

<br>

[Up to the tutorial index](../#readme)
