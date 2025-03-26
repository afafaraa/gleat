import gleam/dict.{type Dict}
import gleam/io
import repository/ini
import simplifile

pub type GleatRepository {
  GleatRepository(
    worktree: String,
    conf: Dict(String, Dict(String, String)),
    gleatdir: String,
  )
}

pub fn get_repo(force: Bool) -> GleatRepository {
  let assert Ok(worktree) = simplifile.current_directory()
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

  let conf = ini.to_dict(ini.append_list_to_path(gleatdir, ["config"], False))

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
