import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/list
import sqlight
import stuffdb/types.{type TableInfo}

pub fn decoder_for_table(
  table_info: TableInfo,
) -> Result(Decoder(List(Dynamic)), sqlight.Error) {
  Ok(add_column_to_decoder(0, [], list.length(table_info)))
}

fn add_column_to_decoder(
  index: Int,
  decode_list: List(Dynamic),
  col_number: Int,
) -> decode.Decoder(List(Dynamic)) {
  use value <- decode.field(index, decode.dynamic)
  let new_list = list.append(decode_list, [value])
  case index == col_number - 1 {
    True -> decode.success(new_list)
    False -> add_column_to_decoder(index + 1, new_list, col_number)
  }
}
