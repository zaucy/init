def rm-symlink [link_name: path] {
  if $nu.os-info.family == 'windows' {
    let query_result = ^fsutil reparsepoint query $link_name | complete;
    if $query_result.exit_code != 0 {
        error make { msg: $"($link_name) is not a symlink or junction: ($query_result.stdout)" }
    }

    # Decide file vs directory link
    if ($link_name | path type) == "dir" {
		let delete_result = ^fsutil reparsepoint delete $link_name | complete;
		if $delete_result.exit_code != 0 {
			error make { msg: "failed to delete junction" }
		}
    } else {
        rm --force $link_name;
    }
  } else {
	  rm $link_name;
  }
}

# Create a symlink
export def symlink [
  existing: path   # The existing file
  link_name: path  # The name of the symlink
  --force          # Delete if already exists
] {
  let existing = ($existing | path expand);

  if not ($existing | path exists) {
    error make {msg: ("path " + $existing + " does not exist")}
  }

  if ($link_name | path exists) {
    if not $force {
        error make {msg: ("destination path " + $link_name + " already exists")}
    } else {
		rm-symlink $link_name;
    }
  }

  if $nu.os-info.family == 'windows' {
	mkdir ($existing | path dirname);
    if ($existing | path type) == 'dir' {
      let make_junction_result = mklink /J $link_name $existing | complete;
	  if $make_junction_result.exit_code != 0 {
        error make {msg: $"failed to make junction ($link_name) <-> ($existing): ($make_junction_result.stdout)"}
	  }
    } else {
      mklink /H $link_name $existing
    }
  } else {
    ln -s $existing $link_name | ignore
  }
}
