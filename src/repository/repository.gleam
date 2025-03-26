import gleam/dict.{type Dict}
import gleam/io
import gleam/result
import repository/ini
import simplifile

pub type GleatRepository {
  GleatRepository(
    worktree: String,
    conf: Dict(String, Dict(String, String)),
    gleatdir: String,
  )
}

// Converts path and list to path:
// append_list_to_path(path, [to, my, file]) -> path/to/my/file
// With flag mkdir=True it also will create directories that are missing
fn append_list_to_path(
  base_path: String,
  path: List(String),
  mkdir: Bool,
) -> String {
  case path {
    [el, ..rest] -> {
      case mkdir {
        True -> {
          case simplifile.create_directory(base_path <> "/" <> el) {
            Ok(_) -> Nil
            Error(e) -> {
              io.println(
                "[INFO]: Directory"
                <> base_path
                <> "/"
                <> el
                <> " already exists, or "
                <> simplifile.describe_error(e)
                <> ". Skipping...",
              )
              Nil
            }
          }
          Nil
        }
        False -> Nil
      }
      append_list_to_path(base_path <> "/" <> el, rest, mkdir)
    }
    [] -> base_path
  }
}

pub fn init(path: String) -> GleatRepository {
  case simplifile.is_directory(path) {
    Ok(res) -> {
      case res {
        True -> True
        False -> {
          io.print_error("[ERROR]: Not a directory: " <> path)
          panic
        }
      }
    }
    Error(e) -> {
      io.print_error(simplifile.describe_error(e))
      panic
    }
  }

  let gleatdir = append_list_to_path(path, [".gleat"], True)
  append_list_to_path(gleatdir, ["refs", "tags"], True)
  append_list_to_path(gleatdir, ["refs", "heads"], True)
  append_list_to_path(gleatdir, ["objects"], True)
  append_list_to_path(gleatdir, ["branches"], True)

  result.unwrap(
    simplifile.create_file(append_list_to_path(gleatdir, ["description"], False)),
    Nil,
  )
  result.unwrap(
    simplifile.write(
      append_list_to_path(gleatdir, ["description"], False),
      "Unnamed repository; edit this file 'description' to name the repository.\n",
    ),
    Nil,
  )
  result.unwrap(
    simplifile.create_file(append_list_to_path(gleatdir, ["HEAD"], False)),
    Nil,
  )
  result.unwrap(
    simplifile.write(
      append_list_to_path(gleatdir, ["HEAD"], False),
      "ref: refs/heads/master\n",
    ),
    Nil,
  )
  result.unwrap(
    simplifile.create_file(append_list_to_path(gleatdir, ["config"], False)),
    Nil,
  )

  let conf = ini.to_dict(append_list_to_path(gleatdir, ["config"], False))
  conf
  |> dict.insert("core", case dict.get(conf, "core") {
    Ok(res) -> {
      dict.merge(
        res,
        dict.from_list([
          #("repositoryformatversion", "0"),
          #("filemode", "false"),
          #("bare", "false"),
        ]),
      )
    }
    Error(_) -> {
      dict.from_list([
        #("repositoryformatversion", "0"),
        #("filemode", "false"),
        #("bare", "false"),
      ])
    }
  })
  |> ini.write_from_dict(append_list_to_path(gleatdir, ["config"], False))

  GleatRepository(
    path,
    ini.to_dict(append_list_to_path(gleatdir, ["config"], False)),
    gleatdir,
  )
}

pub fn get_repo(force: Bool) -> GleatRepository {
  let assert Ok(worktree) = simplifile.current_directory()
  let gleatdir = append_list_to_path(worktree, [".gleat"], False)

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

  case simplifile.is_file(append_list_to_path(gleatdir, ["config"], False)) {
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

  let conf = ini.to_dict(append_list_to_path(gleatdir, ["config"], False))

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
