import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn split_once(arr: BitArray, char: Int) -> List(BitArray) {
  split_once_helper(arr, char, [<<>>, <<>>])
}

pub fn to_int(arr: BitArray) -> Int {
  to_int_helper(arr, [])
  |> result.unwrap([])
  |> int.undigits(10)
  |> result.unwrap(-1)
}

pub fn dec_to_string_hex(arr: BitArray) -> String {
  dec_to_string_hex_helper(arr, "")
}

fn dec_to_string_hex_helper(arr: BitArray, res: String) -> String {
  case arr {
    <<byte, bytes:bytes>> -> {
      let app = case int.to_base16(byte) |> string.length {
        1 -> {
          string.append(res, string.append("0", int.to_base16(byte)))
        }
        _ -> {
          string.append(res, int.to_base16(byte))
        }
      }

      dec_to_string_hex_helper(bytes, app)
    }
    _ -> res
  }
}

fn to_int_helper(arr: BitArray, res: List(Int)) -> Result(List(Int), Nil) {
  case arr {
    <<byte, bytes:bytes>> -> {
      case byte >= 48 && byte <= 57 {
        True -> {
          to_int_helper(bytes, list.append(res, [byte - 48]))
        }
        False -> {
          io.println("[ERROR]: bit array not representing an integer number!")
          Error(Nil)
        }
      }
    }
    _ -> {
      Ok(res)
    }
  }
}

fn split_once_helper(arr: BitArray, char: Int, res: List(BitArray)) {
  case arr {
    <<byte, bytes:bytes>> -> {
      case byte == char {
        True -> {
          let assert Ok(temp) = list.first(res)
          [temp, bytes]
        }
        False -> {
          let assert Ok(temp) = list.first(res)
          let appended = bit_array.append(temp, <<byte>>)
          split_once_helper(bytes, char, [appended, <<>>])
        }
      }
    }
    _ -> res
  }
}
