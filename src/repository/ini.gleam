import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import simplifile

// Converts path and list to path:
// append_list_to_path(path, [to, my, file]) -> path/to/my/file
// With flag mkdir=True it also will create directories that are missing
pub fn append_list_to_path(
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

// Takes ini filepath and returns a list of lines, that are not comments
// On error it returns ["error message"]
pub fn to_list(path: String) -> List(String) {
  case simplifile.read(path) {
    Ok(content) -> content
    Error(e) -> {
      simplifile.describe_error(e)
    }
  }
  |> string.split("\r\n")
  |> list.map(fn(el) { string.trim(el) })
  |> list.filter(fn(line) { !string.starts_with(line, "#") })
  |> echo
}

fn to_dict_inter(
  res: Dict(String, Dict(String, String)),
  arr: List(String),
  current_section: String,
) {
  case arr {
    [""] -> {
      dict.new()
    }
    [el, ..rest] -> {
      case string.starts_with(el, "[") && string.ends_with(el, "]") {
        True -> {
          dict.insert(
            res,
            string.slice(el, 1, string.length(el) - 2),
            dict.new(),
          )
          |> to_dict_inter(rest, string.slice(el, 1, string.length(el) - 2))
        }
        False -> {
          case string.split_once(el, "=") {
            Ok(#(key, value)) -> {
              case dict.get(res, current_section) {
                Ok(current_config) -> {
                  dict.insert(current_config, key, value)
                  |> fn(d) { dict.insert(res, current_section, d) }
                }
                _ -> {
                  io.print_error(
                    "[ERROR]: Cannot find " <> current_section <> " in dict",
                  )
                  dict.new()
                }
              }
            }
            Error(_) -> {
              io.print_error("[ERROR]: Substring not present")
              dict.new()
            }
          }
          |> to_dict_inter(rest, current_section)
        }
      }
    }
    _ -> {
      res
    }
  }
}

// Converts list of lines from ini file and returns coresponding dictionary
// {
//    section_title: {
//      config_key: config_value,
//      ...
//    },
//    ...
// }
pub fn to_dict(path: String) -> Dict(String, Dict(String, String)) {
  to_list(path)
  |> fn(arr) { to_dict_inter(dict.new(), arr, "") }
}

// Gets config value from dictionary returned from to_dict frunction
pub fn get_from_dict(
  ini: Dict(String, Dict(String, String)),
  section,
  key,
) -> String {
  case dict.get(ini, section) {
    Ok(res) -> {
      case dict.get(res, key) {
        Ok(val) -> {
          val
        }
        _ -> {
          io.print_error(
            "[ERROR]: could not resolve " <> key <> " in ini file.",
          )
          ""
        }
      }
    }
    _ -> {
      io.print_error(
        "[ERROR]: could not resolve " <> section <> " in ini file.",
      )
      ""
    }
  }
}

pub fn write_from_dict(
  ini: Dict(String, Dict(String, String)),
  filepath: String,
) {
  let assert Ok(_) = simplifile.write(filepath, "")
  ini
  |> dict.each(fn(title, section) {
    echo title
    let assert Ok(_) = simplifile.append(filepath, "[" <> title <> "]\r\n")
    section
    |> dict.each(fn(key, value) {
      echo key
      echo value
      let assert Ok(_) =
        simplifile.append(filepath, key <> "=" <> value <> "\r\n")
    })
  })
}
