import repository/gleat_obj
import repository/repository

pub fn show(workdir, obj_type, object) {
  let repo = repository.find_repo(workdir, False)
  let obj =
    gleat_obj.read_obj(repo, gleat_obj.find_obj(repo, object, obj_type, True))
  echo obj
}
