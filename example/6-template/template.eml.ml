let render param =
  <html>
    <body>
      <h1>The URL parameter was <%s param %>!</h1>
    </body>
  </html>

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/:word"
      (fun request ->
        Dream.param "word" request
        |> render
        |> Dream.respond);

  ]
  @@ Dream.not_found
