import gleam/bit_array
import gleeunit
import gleeunit/should
import repository/gleat_obj.{Tree}
import repository/repository
import simplifile

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in init command
pub fn test_init() {
  todo
  //delets .gleat dir
  //runs init
  //checks created files, directories and content
}

pub fn test_obj_write() {
  let assert Ok(worktree) = simplifile.current_directory()
  let tree =
    Tree(bit_array.from_string("tree"), <<
      49, 48, 48, 54, 52, 52, 32, 82, 101, 97, 100, 109, 101, 46, 109, 100, 0,
      190, 131, 94, 119, 10, 48, 75, 230, 143, 45, 36, 11, 68, 144, 124, 168,
      250, 52, 78, 177, 49, 48, 48, 54, 52, 52, 32, 108, 97, 98, 95, 54, 46, 105,
      112, 121, 110, 98, 0, 236, 137, 76, 183, 141, 194, 197, 68, 248, 178, 220,
      124, 138, 168, 138, 159, 169, 128, 177, 47,
    >>)
  let repo = repository.find_repo(worktree, False)
  gleat_obj.write_obj(tree, repo)
}
