import argv
import commands/init
import commands/show
import gleam/bit_array
import gleam/io
import repository/gleat_obj.{Tree}
import repository/repository
import simplifile

pub fn main() {
  io.println("Hello from gleat!")
  let assert Ok(worktree) = simplifile.current_directory()

  case argv.load().arguments {
    ["add", ..] -> "[INFO] added"
    ["show", obj_type, object] -> {
      show.show(worktree, obj_type, object)
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
