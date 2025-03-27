import argv
import commands/init
import gleam/io
import repository/gleat_obj
import repository/ini
import simplifile

pub fn main() {
  io.println("Hello from gleat!")
  let assert Ok(worktree) = simplifile.current_directory()

  case argv.load().arguments {
    ["add", ..] -> "[INFO] added"
    ["cat-file", ..] -> ""
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
      let assert Ok(val) = simplifile.current_directory()
      init.init(worktree)
      |> gleat_obj.read_object("5cb6827c4732fbdc5152dbfa886ec19a183cdb49")
      |> echo
      ""
    }
    _ -> "[ERROR]: Unknown gleat command!"
  }
  |> echo
}
