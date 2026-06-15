import gleam/dynamic/decode
import sqlight

pub fn main() {
  use conn <- sqlight.with_connection("file:mydb?mode=memory")
  let sql =
    "
  create table cats (name text, age int);

  insert into cats (name, age) values 
  ('Nubi', 4),
  ('Biffy', 10),
  ('Ginny', 6);
  "
  let _ = sqlight.exec(sql, conn)

  let cat_decoder = {
    use name <- decode.field(0, decode.string)
    use age <- decode.field(1, decode.int)
    decode.success(#(name, age))
  }

  let sql =
    "
  select name, age from cats
  where age < ?
  "
  echo sqlight.query(
    sql,
    on: conn,
    with: [sqlight.int(7)],
    expecting: cat_decoder,
  )
}
