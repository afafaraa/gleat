import gleam/bit_array
import gleam/crypto
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gzlib
import repository/bit_array_ext
import repository/ini
import repository/repository.{type GleatRepository}
import simplifile

pub type GleatError {
  ObjectReadError
  ObjectWriteError
}

pub type GleatObject {
  Blob(fmt: BitArray, data: BitArray)
  Commit(fmt: BitArray, data: BitArray)
  Tree(fmt: BitArray, data: BitArray)
  Tag(fmt: BitArray, data: BitArray)
}

pub fn serialize(obj: GleatObject) -> BitArray {
  obj.data
}

pub fn read_obj(
  repo: GleatRepository,
  sha: String,
) -> Result(GleatObject, GleatError) {
  let path =
    ini.append_list_to_path(
      repo.gleatdir,
      [
        "objects",
        string.slice(sha, 0, 2),
        string.slice(sha, 2, string.length(sha) - 2),
      ],
      False,
      False,
    )

  let is_file = result.unwrap(simplifile.is_file(path), False)

  case is_file {
    True -> {
      let compressed = simplifile.read_bits(path) |> result.unwrap(<<>>)
      let raw: BitArray = gzlib.uncompress(compressed)
      let fmt =
        bit_array_ext.split_once(raw, 32) |> list.first |> result.unwrap(<<>>)
      let rest =
        bit_array_ext.split_once(raw, 32) |> list.last |> result.unwrap(<<>>)

      let encoded_size =
        bit_array_ext.split_once(rest, 0)
        |> list.first
        |> result.unwrap(<<>>)

      let data =
        bit_array_ext.split_once(rest, 0)
        |> list.last
        |> result.unwrap(<<>>)

      let size = encoded_size |> bit_array_ext.to_int
      let index_of_null =
        bit_array.byte_size(encoded_size) + bit_array.byte_size(fmt) + 1
      let size_of_raw = bit_array.byte_size(raw)

      let controll_sum = size_of_raw - index_of_null - 1

      case size == controll_sum {
        True -> {
          case bit_array.to_string(fmt) |> result.unwrap("") {
            "commit" -> Ok(Commit(fmt, data))
            "tree" -> Ok(Tree(fmt, data))
            "tag" -> Ok(Tag(fmt, data))
            "blob" -> Ok(Blob(fmt, data))
            _ -> Error(ObjectReadError)
          }
        }
        _ -> Error(ObjectReadError)
      }
    }
    False -> {
      Error(ObjectReadError)
    }
  }
}

pub fn write_obj(obj: GleatObject, repo: GleatRepository) {
  let data = serialize(obj)
  let len = bit_array.byte_size(data) |> int.to_string |> bit_array.from_string
  let result = bit_array.concat([obj.fmt, <<32>>, len, <<0>>, data])
  let sha = crypto.hash(crypto.Sha1, result) |> bit_array_ext.dec_to_string_hex
  echo sha
  let path =
    ini.append_list_to_path(
      repo.gleatdir,
      [
        "objects",
        string.slice(sha, 0, 2),
        string.slice(sha, 2, string.length(sha) - 2),
      ],
      True,
      True,
    )
  case path {
    "" -> Nil
    _ -> {
      result.unwrap(simplifile.write_bits(path, gzlib.compress(result)), Nil)
    }
  }
}
