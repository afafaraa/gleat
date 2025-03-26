import argv
import gleam/io
import repository/repository
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
      repository.init(worktree)
      "Initialazed empty gleat repository"
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
