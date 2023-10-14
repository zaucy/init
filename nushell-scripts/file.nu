# Create a symlink
export def symlink [
  existing: path   # The existing file
  link_name: path  # The name of the symlink
  --force          # Delete if already exists
] {
  let existing = ($existing | path expand)
  let link_name = ($link_name | path expand)

  if not ($existing | path exists) {
    error make {msg: ("path " + $existing + " does not exist")}
    return
  }

  if ($link_name | path exists) and $force {
    rm $link_name;
  }

  if ($link_name | path exists) {
    error make {msg: ("destination path " + $link_name + " already exists")}
    return
  }

  if $nu.os-info.family == 'windows' {
    if ($existing | path type) == 'dir' {
      mklink /J $link_name $existing
    } else {
      mklink /H $link_name $existing
    }
  } else {
    ln -s $existing $link_name | ignore
  }
}
