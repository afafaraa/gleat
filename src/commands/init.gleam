import gleam/dict
import gleam/io
import gleam/result
import repository/ini
import repository/repository
import simplifile

pub fn init(path: String) -> repository.GleatRepository {
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

  let gleatdir = ini.append_list_to_path(path, [".gleat"], True, False)
  ini.append_list_to_path(gleatdir, ["refs", "tags"], True, False)
  ini.append_list_to_path(gleatdir, ["refs", "heads"], True, False)
  ini.append_list_to_path(gleatdir, ["objects"], True, False)
  ini.append_list_to_path(gleatdir, ["branches"], True, False)

  result.unwrap(
    simplifile.create_file(ini.append_list_to_path(
      gleatdir,
      ["description"],
      False,
      False,
    )),
    Nil,
  )
  result.unwrap(
    simplifile.write(
      ini.append_list_to_path(gleatdir, ["description"], False, False),
      "Unnamed repository; edit this file 'description' to name the repository.\n",
    ),
    Nil,
  )
  result.unwrap(
    simplifile.create_file(ini.append_list_to_path(
      gleatdir,
      ["HEAD"],
      False,
      False,
    )),
    Nil,
  )
  result.unwrap(
    simplifile.write(
      ini.append_list_to_path(gleatdir, ["HEAD"], False, False),
      "ref: refs/heads/master\n",
    ),
    Nil,
  )
  result.unwrap(
    simplifile.create_file(ini.append_list_to_path(
      gleatdir,
      ["config"],
      False,
      False,
    )),
    Nil,
  )

  let conf =
    ini.to_dict(ini.append_list_to_path(gleatdir, ["config"], False, False))
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
  |> ini.write_from_dict(ini.append_list_to_path(
    gleatdir,
    ["config"],
    False,
    False,
  ))

  repository.GleatRepository(
    path,
    ini.to_dict(ini.append_list_to_path(gleatdir, ["config"], False, False)),
    gleatdir,
  )
}
