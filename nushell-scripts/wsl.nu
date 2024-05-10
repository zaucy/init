def wsl-cd [] {
	mut pwd = ($env.PWD)

	if ('USERPROFILE' in $env) and ($pwd | str starts-with $env.USERPROFILE) {
		$pwd = '~' + ($pwd | str substring ($env.USERPROFILE | str length)..($pwd | str length));
  }

	$pwd = ($pwd | str replace '\' '/' -a);

  wsl --cd $pwd
}

def --wrapped wsl-bazelisk [...args: string] {
  wsl -e '/home/ezekiel/.local/bin/bazelisk' ...$args
}

def --wrapped wsl-bazel [...args: string] {
  wsl -e '/home/ezekiel/.local/bin/bazel' ...$args
}

def --wrapped wsl-bazel-dbg [...args: string] {
  wsl -e '/home/ezekiel/.cargo/bin/bazel-dbg' --bazel-path '/home/ezekiel/.local/bin/bazelisk' ...$args
}

def --wrapped wslx [executable: string, ...args: string] {
  wsl -e $"/home/ezekiel/.local/bin/($executable)" ...$args
}

def --wrapped wslsh [...args: string] {
  wsl --shell-type login -- ...$args
}
