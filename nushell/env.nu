# TODO: This doesn't work anymore
# use ~/projects/zaucy/init/nushell-scripts/nu_scripts/modules/prompt/async_git_prompt/async-git-prompt.nu *

def get_box_color [] {
	if ($env.LAST_EXIT_CODE == 0) {
		ansi grey
	} else {
		ansi red
	}
}

def prompt-concat [parts: table] {
	$parts
	| where (not ($it.text | is-empty))
	| each { |it| $"($it.color)($it.text)" }
	| str join ' '
}

def prompt-git-branch [] {
	let branch = do -i { git rev-parse --abbrev-ref HEAD | str trim -r};

	if ($branch | is-empty) {
		""
	} else {
		(" " + $branch)
	}
}

def create_left_prompt [] {
	mut pwd = ($env.PWD)

	if ('USERPROFILE' in $env) and ($pwd | str starts-with $env.USERPROFILE) {
		$pwd = '~' + ($pwd | str substring ($env.USERPROFILE | str length)..($pwd | str length))
	} else if ('HOME' in $env) and ($pwd | str starts-with $env.HOME) {
		$pwd = '~' + ($pwd | str substring ($env.HOME | str length)..($pwd | str length))
	}

	$pwd = ($pwd | str replace '\' '/' --all)
	mut prefix = "";

	let main_color = if (is-admin) {
		ansi red_bold
	} else {
		ansi green_bold
	};

	let box_color = get_box_color;

	if (is-admin) {
		$prefix += $"(ansi red) ";
	}

	if 'WSL_DISTRO_NAME' in $env {
		$prefix += $"(ansi -e {fg: '#dd4814'}) (ansi reset)";
	}

	prompt-concat [
		[text color];
		["╭─⦗" $box_color]
		[$prefix $main_color]
		[$pwd $main_color]
		["⦘" $box_color]
		# [(prompt-git-branch)  (ansi blue_bold)]
	]
}

def create_right_prompt [] {
	""
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

$env.PROMPT_INDICATOR = {|| $"\r\n(get_box_color)╰〉(ansi reset)" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "〉" }
$env.PROMPT_MULTILINE_INDICATOR = {|| ":: " }

$env.ENV_CONVERSIONS = {
	"PATH": {
		from_string: { |s| $s | split row (char esep) | path expand -n }
		to_string: { |v| $v | path expand -n | str join (char esep) }
	}
	"Path": {
		from_string: { |s| $s | split row (char esep) | path expand -n }
		to_string: { |v| $v | path expand -n | str join (char esep) }
	}
}

$env.HELIX_RUNTIME = ('~/projects/helix-editor/helix/runtime' | path expand)

def --env PATH-prepend [p] {
	if 'PATH' in $env {
		$env.PATH = ($env.PATH | prepend $p)
	}

	if 'Path' in $env {
		$env.Path = ($env.Path | prepend $p)
	}
}

def --env PATH-append [p] {
	if 'PATH' in $env {
		$env.PATH = ($env.PATH | append $p)
	}

	if 'Path' in $env {
		$env.Path = ($env.Path | append $p)
	}
}


$env.NU_LIB_DIRS = [
	($nu.config-path | path dirname | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
	($nu.config-path | path dirname | path join 'plugins')
]

$env.HELIX_RUNTIME = ("~/projects/helix-editor/helix/runtime" | path expand)

PATH-append '~/.local/bin'
PATH-append '~/.cargo/bin'
