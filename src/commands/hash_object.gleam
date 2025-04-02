import gleam/bit_array
import gleam/result
import repository/gleat_obj.{type GleatObject}
import repository/repository
import simplifile

pub fn hash_object(
  worktree: String,
  write: Bool,
  object_type: String,
  path: String,
) {
  let repo = repository.find_repo(worktree, False)
  let data = simplifile.read_bits(path) |> result.unwrap(<<>>)
  let obj = gleat_obj.create_obj(data, object_type)

  case obj {
    Error(_) -> {
      Nil
    }
    Ok(obj) -> {
      case write {
        True -> {
          gleat_obj.write_obj(obj, repo)
          Nil
        }
        False -> {
          Nil
        }
      }
      Nil
    }
  }
}
