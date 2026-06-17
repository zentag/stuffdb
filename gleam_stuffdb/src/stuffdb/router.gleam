import gleam/http.{Get}
import sqlight.{type Connection}
import stuffdb/decoder
import stuffdb/render
import stuffdb/table_info
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, conn: Connection) -> Response {
  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req)
    ["table"] -> table(req, conn)
    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

fn require_ok(result: Result(a, e), next: fn(a) -> Response) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(_) -> wisp.internal_server_error()
  }
}

fn table(req: Request, conn: Connection) -> Response {
  use <- wisp.require_method(req, Get)

  let sql = "select * from cats"

  use info <- require_ok(table_info.get_columns("cats", conn))
  use decoder <- require_ok(decoder.decoder_for_table(info))
  use results <- require_ok(
    sqlight.query(sql, on: conn, expecting: decoder, with: []),
  )

  wisp.ok()
  |> wisp.html_body(render.render_table(results, info, "<table>"))
}

fn home_page(req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  wisp.ok()
  |> wisp.html_body("Hello, Joe!")
}
