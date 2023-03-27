def create_left_prompt [] {
	mut pwd = ($env.PWD)

	if ('USERPROFILE' in $env) and ($pwd | str starts-with $env.USERPROFILE) {
		$pwd = '~' + ($pwd | str substring [($env.USERPROFILE | str length) ($pwd | str length)])
	}

	$pwd = ($pwd | str replace '\\' '/' --all)

	let path_segment = if (is-admin) {
		$"(ansi red_bold)($pwd) 🛡 "
	} else {
		$"(ansi green_bold)($pwd)"
	}

	$path_segment
}

def create_right_prompt [] {
}

let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }

let-env PROMPT_INDICATOR = { "〉" }
let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "〉" }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

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

let-env NU_LIB_DIRS = [
	($nu.config-path | path dirname | path join 'scripts')
]

let-env NU_PLUGIN_DIRS = [
	($nu.config-path | path dirname | path join 'plugins')
]

source-env ~/.fnm/fnm_env.nu
