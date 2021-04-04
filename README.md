# Dream (project and README WIP)

Dream is an easy-to-use, feature-complete Web framework without any boilerplate.

```ocaml
let hello who =
  <html>
    <body>
      <h1>Hello, <%s who %>!</h1>
    </body>
  </html>

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.respond (hello "world"));
  ]
  @@ Dream.not_found
```

<br>

All of Dream is [one flat module][api-main], and one package, `dream`. Included
are:

- Easy **HTTPS** and **HTTP/2** support, so you can choose to run Dream without
  a proxy.
- [**WebSockets**][websocket] and [**GraphQL**][graphql] for your modern Web
  apps.
- [**HTML templates**][templates] with embedded OCaml &mdash; use existing
  skills!
- Composable [**middleware**][middleware] and [**routes**][routing].
- Easy-to-use to functions for [**secure cookies**][cookies] and
  [**CSRF-safe forms**][forms].
- [**Sessions**][sessions] with pluggable storage [back ends][back-ends].
- Unified, internationalization-friendly [**error handling**][errors].
- [**Cryptography**][crypto] helpers, key rotation, and a chosen cipher.
- A neat [**logger**][logging], and attention to configuring the OCaml runtime
  nicely.

<br>

Every part of the API is arranged to be easy to use, understand, and remember.
Dream sticks to base OCaml types like `string` and `list`, introducing only a
few [types][types] of its own &mdash; and some of those are just abbreviations
for bare functions!

The neat interface is not a limitation. Everything is still configurable by a
large number of optional arguments. Where necessary, Dream exposes the
lower-level machinery that it is composed from. For example, the default body
and WebSocket readers return strings, but you can also do [zero-copy
streaming][streaming].

You can even run Dream as a [quite bare abstraction][raw] over its [underlying
set of HTTP libraries][vendor], where it acts only as minimal glue code between
their slightly different interfaces.

[websocket]: https://aantron.github.io/dream/#websockets
[graphql]: https://aantron.github.io/dream/#graphql
[templates]: https://github.com/aantron/dream/tree/master/example/6-template#files
[middleware]: https://github.com/aantron/dream/tree/master/example/4-counter#files
[routing]: https://aantron.github.io/dream/#routing
[cookies]: https://github.com/aantron/dream/tree/master/example/c-cookie#files
[forms]: https://github.com/aantron/dream/tree/master/example/d-form#files
[sessions]: https://github.com/aantron/dream/tree/master/example/b-session
[back-ends]: https://aantron.github.io/dream/#back-ends
[errors]: https://github.com/aantron/dream/tree/master/example/8-error#files
[crypto]: https://aantron.github.io/dream/#cryptography
[logging]: https://aantron.github.io/dream/#logging
[types]: https://aantron.github.io/dream/#types
[streaming]: https://aantron.github.io/dream/#streaming
[raw]: https://aantron.github.io/dream/#builtin

<br>

## Documentation

- Dream has several dozen [**Examples**][examples], each of which is a complete
  project in the public domain.

- The first examples make up a [**Tutorial**][examples]. Visit to see the full
  list and start wherever you  like, or begin at [**`1-hello`**][1-hello], the
  Dream version of *Hello, world!*

- See the [**API documentation**][api-main].

[examples]: https://github.com/aantron/dream/tree/master/example#readme
[1-hello]: https://github.com/aantron/dream/tree/master/example/1-hello#files

<!-- TODO Show templates. -->

<!-- TODO LATER Coverage badge on coveralls; better yet, link to an online version of
     the Bisect coverage report - probably in gh-pages. Generate the badge
     from coveralls, though - it's easier to maintain. -->
<!-- TODO LATER CI badges, opam link badge, npm badge. -->
<!-- TODO Clone instructions should include --recursive. -->

<br>

## Getting started

```
opam install dream
```

[api-main]: https://aantron.github.io/dream/#types

<br>

## Acknowledgements

Dream is based on work by the authors and contributors of its many
[dependencies][opamfile] and their transitive dependencies. There are, however,
several influences that cannot be discovered directly:

- Templates are inspired by [ECaml][ecaml] from [Alexander Markov][komar], and
  [Embedded OCaml Templates][eot] from [Emile Trotignon][trotignon].
- Dream's handlers and middlewares are directly inspired by [Opium][opium] from
  [Rudi Grinberg][rgrinberg] and contributors.
- The lower-level HTTP and WebSocket servers are [vendored][vendor] copies of
  [Antonio Nuno Monteiro][anmonteiro]'s forks and original works, with credit
  also due to their contributors, and [Spiros Eliopoulos][seliopou] in
  particular, as the original author of two of the projects.
- The API docs are instantiated by [Soupault][soupault] from
  [Daniil Baturin][dmbaturin].
- The name was inspired by [Morph][morph] from [Ulrik Strid][ulrikstrid], which
  was itself partially inspired by [Opium][opium].
- [Raphael Rafatpanah][persianturtle] and [El-Hassan Wanas][foocraft] provided
  important early feedback.

[ecaml]: http://komar.in/en/code/ecaml
[komar]: https://github.com/apsheronets
[eot]: https://github.com/EmileTrotignon/embedded_ocaml_templates
[trotignon]: https://github.com/EmileTrotignon
[opamfile]: https://github.com/aantron/dream/blob/master/dream.opam
[opium]: https://github.com/rgrinberg/opium
[vendor]: https://github.com/aantron/dream/tree/master/src/vendor
[rgrinberg]: https://github.com/rgrinberg
[anmonteiro]: https://github.com/anmonteiro
[soupault]: https://github.com/dmbaturin/soupault
[dmbaturin]: https://github.com/dmbaturin
[morph]: https://github.com/reason-native-web/morph
[ulrikstrid]: https://github.com/ulrikstrid
[seliopou]: https://github.com/seliopou
[persianturtle]: https://github.com/persianturtle
[foocraft]: https://github.com/foocraft

<br>

## Roadmap

1.0.0~alpha1:

- [ ] Finish more of the examples, cross-link everything.
- [ ] Correct the cipher rotation envelope scheme.
- [ ] Quick start script.

Then:

- [ ] Optimizations: router, logger, microparsers (form data, etc.), fully
      zero-allocation streaming.
- [ ] WebSocket and stream backpressure.
- [ ] HTTP3/QUIC.



<!-- Example install: how to install opam, how to install deps, add to Makefile
     targets. -->
<!-- TODO dune-workspace at root for examples -->
<!-- get rid of all warnings in examples -->
<!-- opam install examples from example dirs, its a mess right now. -->
<!-- warning ~mask in websocketaf, use --profile release anyway -->
<!-- ::1 IPv6 -->
<!-- hyperlink localhost in examples -->
<!-- ld: /opt/local/libn ot found on mac -->
<!-- crumb noise? dream.param -->
<!-- Path parsing of # $ in targets -->
<!-- update code in exampels -->
<!-- Reason example -->
<!-- Reason mode in docs -->
<!-- examples: are exceptions isolated? yes -->
<!-- Ctrl+C needed to get out of error page caues of no content-legnth -->
<!-- Remove name in ddbug_dump paramter. -->
<!-- content-length not autp-added in error handlers anymore -->
<!-- esy workflow -->
<!-- Remove license headers from examples. add note about public domain to README. -->
<!-- snag: clone must be recursive. -->
<!-- Convert to using lwt_ppx. -->
