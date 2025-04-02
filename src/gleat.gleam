import argv
import commands/hash_object
import commands/init
import commands/show
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/result
import repository/gleat_obj.{Tree}
import repository/repository
import simplifile

pub fn main() {
  io.println("Hello from gleat!")
  let assert Ok(worktree) = simplifile.current_directory()

  case argv.load().arguments {
    ["add", ..] -> "[INFO] added"
    ["show", "-sha", sha, obj_type] -> {
      let repo = repository.find_repo(worktree, False)
      gleat_obj.read_obj(repo, sha)
      |> echo
      ""
    }
    ["show", obj_type, object] -> {
      show.show(worktree, obj_type, object)
      |> echo
      ""
    }
    ["hash-object", "-w", "-t", obj_type, path] -> {
      hash_object.hash_object(worktree, True, obj_type, path)
      |> echo
      ""
    }
    ["hash-object", "-t", obj_type, file] -> {
      ""
    }
    ["checkout", ..] -> ""
    ["commit", ..] -> ""
    ["init", ..] -> {
      init.init(worktree)
      |> echo
      "[INFO] Initialazed empty gleat repository"
    }
    ["log", ..] -> ""
    ["status", ..] -> ""
    ["test", ..] -> {
      ""
    }
    _ -> "[ERROR]: Unknown gleat command!"
  }
  |> echo
}
