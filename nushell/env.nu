def create_left_prompt [] {
	mut pwd = ($env.PWD)

	if ('USERPROFILE' in $env) and ($pwd | str starts-with $env.USERPROFILE) {
		$pwd = '~' + ($pwd | str substring ($env.USERPROFILE | str length)..($pwd | str length))
	} else if ('HOME' in $env) and ($pwd | str starts-with $env.HOME) {
		$pwd = '~' + ($pwd | str substring ($env.HOME | str length)..($pwd | str length))
	}

	$pwd = ($pwd | str replace '\\' '/' --all)

	mut path_segment = if (is-admin) {
		$"(ansi red_bold)($pwd) 🛡 "
	} else {
		$"(ansi green_bold)($pwd)"
	}

	if 'WSL_DISTRO_NAME' in $env {
		$path_segment = $"(ansi -e {fg: '#dd4814'}) ($path_segment)"
	}

	$path_segment
}

def create_right_prompt [] {
}

let-env PROMPT_COMMAND = {|| create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

let-env PROMPT_INDICATOR = {|| "〉" }
let-env PROMPT_INDICATOR_VI_INSERT = {|| ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = {|| "〉" }
let-env PROMPT_MULTILINE_INDICATOR = {|| "::: " }

let-env ENV_CONVERSIONS = {
	"PATH": {
		from_string: { |s| $s | split row (char esep) | path expand -n }
		to_string: { |v| $v | path expand -n | str join (char esep) }
	}
	"Path": {
		from_string: { |s| $s | split row (char esep) | path expand -n }
		to_string: { |v| $v | path expand -n | str join (char esep) }
	}
}

let-env HELIX_RUNTIME = ('~/projects/helix-editor/helix/runtime' | path expand)

def-env PATH-prepend [p] {
	if 'PATH' in $env {
		$env.PATH = ($env.PATH | prepend $p)
	}

	if 'Path' in $env {
		$env.Path = ($env.Path | prepend $p)
	}
}

def-env PATH-append [p] {
	if 'PATH' in $env {
		$env.PATH = ($env.PATH | append $p)
	}

	if 'Path' in $env {
		$env.Path = ($env.Path | append $p)
	}
}


let-env NU_LIB_DIRS = [
	($nu.config-path | path dirname | path join 'scripts')
]

let-env NU_PLUGIN_DIRS = [
	($nu.config-path | path dirname | path join 'plugins')
]

PATH-append '~/.local/bin'
PATH-append '~/.cargo/bin'

source-env ~/.fnm/fnm_env.nu
