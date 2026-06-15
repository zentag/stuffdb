import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import sqlight

pub fn main() {
  use conn <- sqlight.with_connection("file:mydb?mode=memory")
  let sql =
    "
  create table cats (name text, age int not null);

  insert into cats (name, age) values 
  ('Nubi', 4),
  ('Biffy', 10),
  ('Ginny', 6);
  "
  let _ = sqlight.exec(sql, conn)
  use table_info <- result.try(get_columns("cats", conn))
  let decoder = add_column_to_decoder(0, [], list.length(table_info))
  let sql =
    "
    select * from cats
    "
  let _ = sqlight.query(sql, on: conn, expecting: decoder, with: [])
  Ok(echo dynamic_to_string(dynamic.float(10.2)))
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
