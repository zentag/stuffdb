import gleam/dynamic/decode
import sqlight
import stuffdb/types.{type TableInfo}

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
