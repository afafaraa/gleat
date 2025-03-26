import gleam/dict.{type Dict}
import gleam/io
import gleam/string
import repository/ini
import simplifile

pub type GleatRepository {
  GleatRepository(
    worktree: String,
    conf: Dict(String, Dict(String, String)),
    gleatdir: String,
  )
}

pub fn get_repo(path: String, force: Bool) -> GleatRepository {
  let worktree = path
  let gleatdir = ini.append_list_to_path(worktree, [".gleat"], False)

  case simplifile.is_directory(gleatdir) {
    Ok(is_directory) ->
      case is_directory || force {
        True -> {
          True
        }
        False -> {
          io.print_error("[ERROR]: Not a gleat directory ")
          panic
        }
      }
    Error(e) -> {
      io.println(simplifile.describe_error(e))
      panic
    }
  }

  case
    simplifile.is_file(ini.append_list_to_path(gleatdir, ["config"], False))
  {
    Ok(res) -> {
      case res {
        True -> True
        False -> {
          io.print_error("[ERROR]: Config file missing!")
          panic
        }
      }
    }
    Error(e) -> {
      io.println(simplifile.describe_error(e))
      panic
    }
  }

  let conf =
    ini.append_list_to_path(gleatdir, ["config"], False)
    |> ini.to_dict

  case !force {
    True -> {
      case ini.get_from_dict(conf, "core", "repositoryformatversion") {
        "0" -> {
          Nil
        }
        vers -> {
          io.print_error(
            "[ERROR]: Unsupported repositoryformatversion: " <> vers,
          )
          panic
        }
      }
    }
    False -> {
      Nil
    }
  }

  GleatRepository(worktree, conf, gleatdir)
}

pub fn find_repo(current_path: String, _required: Bool) -> GleatRepository {
  case
    simplifile.is_directory(ini.append_list_to_path(
      current_path,
      [".gleat"],
      False,
    ))
  {
    Ok(val) -> {
      case val {
        True -> get_repo(current_path, False)
        False -> {
          case drop_untill(current_path) {
            "Not a git directory" -> {
              io.print_error("Not a git directory")
              GleatRepository("", dict.new(), "")
            }
            path -> find_repo(path, False)
          }
        }
      }
    }
    Error(e) -> {
      io.print_error(simplifile.describe_error(e))
      GleatRepository("", dict.new(), "")
    }
  }
}

fn drop_untill(str: String) -> String {
  case string.last(str) {
    Ok(val) -> {
      case val {
        ":" -> {
          "Not a git directory"
        }
        "/" -> {
          string.drop_end(str, 1) |> echo
        }
        _ -> {
          string.drop_end(str, 1)
          |> drop_untill
        }
      }
    }
    Error(_) -> {
      str
    }
  }
}
