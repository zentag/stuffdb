import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/int
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
  let _ = echo get_columns("cats", conn)
  echo dynamic_to_string(dynamic.float(10.2))
}

fn get_columns(
  table_name: String,
  conn: sqlight.Connection,
) -> Result(List(#(String, String, Int)), sqlight.Error) {
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
