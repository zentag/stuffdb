import gleam/dynamic/decode.{type Dynamic}
import gleam/float
import gleam/int
import gleam/result
import stuffdb/types.{type ColumnInfo, type TableInfo}

pub fn render_table(
  rows: List(List(Dynamic)),
  table_info: TableInfo,
  current: String,
) {
  case rows {
    [row, ..new_rows] -> {
      let current = current <> render_row(table_info, row, "<tr>") <> "</tr>"
      render_table(new_rows, table_info, current)
    }
    [] -> current <> "</table>"
  }
}

pub fn render_row(table_info: TableInfo, row: List(Dynamic), current: String) {
  case table_info, row {
    [col_info, ..cs], [value, ..vs] -> {
      let cell = render_cell(col_info, value)
      render_row(cs, vs, current <> cell)
    }
    _, _ -> current
  }
}

fn render_cell(col_info: ColumnInfo, value: Dynamic) {
  let #(_, datatype, _) = col_info
  case datatype {
    "TEXT" -> {
      let string =
        result.unwrap(decode.run(value, decode.string), "didn'tdecode")
      "<td>" <> string <> "</td>"
    }
    "INT" -> {
      let string =
        // HACK: change unwrapt to something better
        int.to_string(result.unwrap(decode.run(value, decode.int), 0))
      "<td>" <> string <> "</td>"
    }
    "FLOAT" -> {
      let string =
        decode.run(value, decode.float)
        |> result.unwrap(0.0)
        |> float.to_string
      "<td>" <> string <> "</td>"
    }
    // HACK: this is for debugging so I can figure out what the types are I haven't handled
    value -> value
  }
}
