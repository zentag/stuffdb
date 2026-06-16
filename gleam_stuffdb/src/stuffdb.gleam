import gleam/dynamic/decode
import gleam/result
import sqlight
import stuffdb/decoder
import stuffdb/render
import stuffdb/types.{type TableInfo}

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
  echo table_names
  let sql =
    "
    select * from cats
    "
  use table_info <- result.try(get_columns("cats", conn))
  use decoder <- result.try(decoder.decoder_for_table(table_info))
  use dynamic_results <- result.try(
    sqlight.query(sql, on: conn, expecting: decoder, with: []),
  )
  echo render.render_table(dynamic_results, table_info, "<table>")
  Ok(Nil)
}

pub fn get_columns(
  table_name: String,
  conn: sqlight.Connection,
) -> Result(TableInfo, sqlight.Error) {
  let decoder = {
    use name <- decode.field(0, decode.string)
    use col_type <- decode.field(1, decode.string)
    use not_null <- decode.field(2, decode.int)
    decode.success(#(name, col_type, not_null))
  }

  let sql =
    "
    select name, type, \"notnull\" from pragma_table_info(?);
  "
  sqlight.query(
    sql,
    on: conn,
    with: [sqlight.text(table_name)],
    expecting: decoder,
  )
}
