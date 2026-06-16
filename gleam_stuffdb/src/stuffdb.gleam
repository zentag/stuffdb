import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import sqlight

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
  use table_info <- result.try(get_columns("cats", conn))
  let decoder = add_column_to_decoder(0, [], list.length(table_info))
  let sql =
    "
    select * from cats
    "
  use dynamic_results <- result.try(
    sqlight.query(sql, on: conn, expecting: decoder, with: []),
  )
  echo render_table(dynamic_results, table_info, "<table>")
  Ok(Nil)
}

pub fn render_table(
  rows: List(List(dynamic.Dynamic)),
  table_info: TableInfo,
  current: String,
) {
  case rows {
    [row, ..new_rows] -> {
      let current = current <> render_row(table_info, row, "<row>") <> "</row>"
      render_table(new_rows, table_info, current)
    }
    [] -> current <> "</table>"
  }
}

fn render_row(
  table_info: TableInfo,
  row: List(dynamic.Dynamic),
  current: String,
) {
  case table_info, row {
    [col_info, ..cs], [value, ..vs] -> {
      let cell = render_cell(col_info, value)
      render_row(cs, vs, current <> cell)
    }
    _, _ -> current
  }
}

fn render_cell(col_info: ColumnInfo, value: dynamic.Dynamic) {
  let #(_, datatype, _) = col_info
  case datatype {
    "TEXT" -> {
      let string =
        result.unwrap(decode.run(value, decode.string), "didn'tdecode")
      "<p>" <> string <> "</p>"
    }
    "INT" -> {
      let string =
        // HACK: change unwrapt to something better
        int.to_string(result.unwrap(decode.run(value, decode.int), 0))
      "<p>" <> string <> "</p>"
    }
    // HACK: this is for debugging so I can figure out what the types are I haven't handled
    value -> value
  }
}

pub type ColumnInfo =
  #(String, String, Int)

pub type TableInfo =
  List(ColumnInfo)

fn add_column_to_decoder(
  index: Int,
  decode_list: List(dynamic.Dynamic),
  col_number: Int,
) -> decode.Decoder(List(dynamic.Dynamic)) {
  use value <- decode.field(index, decode.dynamic)
  let new_list = list.append(decode_list, [value])
  case index == col_number - 1 {
    True -> decode.success(new_list)
    False -> add_column_to_decoder(index + 1, new_list, col_number)
  }
}

fn get_columns(
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

fn dynamic_to_string(dyn: dynamic.Dynamic) -> String {
  case decode.run(dyn, decode.string) {
    Ok(str) -> str
    Error(_) ->
      case decode.run(dyn, decode.int) {
        Ok(value) -> int.to_string(value)
        Error(_) ->
          case decode.run(dyn, decode.float) {
            Ok(value) -> float.to_string(value)
            Error(_) -> panic
          }
      }
  }
}
