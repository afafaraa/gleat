import gleam/io
import gleam/list
import gleam/string
import gzlib
import repository/ini
import repository/repository.{type GleatRepository}
import simplifile

pub type GleatObject {
  Blob(fmt: BitArray)
}

pub fn init(data: String) {
  case string.length(data) {
    0 -> no_data_init()
    _ -> deserialize(data)
  }
}

fn deserialize(data: String) {
  Nil
}

fn serialize(obj: GleatObject) {
  Nil
}

fn no_data_init() {
  Nil
}

pub fn write_object(obj: GleatObject, repo: GleatRepository) {
  let data = serialize(obj)
}

pub fn read_object(repo: GleatRepository, sha: String) {
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

  case simplifile.read_bits(path) {
    Ok(res) -> {
      gzlib.uncompress(res)
      |> echo
      Nil
    }
    Error(e) -> {
      io.println(simplifile.describe_error(e))
      Nil
    }
  }
}
