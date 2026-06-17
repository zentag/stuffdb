import gleam/dynamic/decode
import gleam/erlang/process
import gleam/result
import mist
import sqlight
import stuffdb/router
import wisp.{type Request}
import wisp/wisp_mist

pub fn main() {
  use conn <- sqlight.with_connection("stuff.db")
  let sql =
    "
    SELECT name FROM sqlite_master WHERE type='table';
    "
  let decoder = {
    use name <- decode.field(0, decode.string)
    decode.success(name)
  }
  use table_names <- result.try(
    sqlight.query(sql, on: conn, expecting: decoder, with: []),
  )
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let handler = fn(req: Request) { router.handle_request(req, conn) }
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
  echo table_names
  Ok(Nil)
}
