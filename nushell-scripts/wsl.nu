def wsl-cd [] {
	mut pwd = ($env.PWD)

	if ('USERPROFILE' in $env) and ($pwd | str starts-with $env.USERPROFILE) {
		$pwd = '~' + ($pwd | str substring ($env.USERPROFILE | str length)..($pwd | str length));
  }

	$pwd = ($pwd | str replace '\' '/' -a);

  wsl --cd $pwd
}
