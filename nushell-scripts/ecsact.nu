def "nu-complete ecsact config keys" [] {
	^ecsact config | from json | columns
}

def "ecsact config --help" [] {
	^ecsact config --help
}

def "ecsact config" [...keys: string@"nu-complete ecsact config keys"] {
	let keys_length = ($keys | length);
	if $keys_length == 1 {
		if ($keys | get 0) == "builtin_plugins" {
			^ecsact config $keys | lines
		} else {
			^ecsact config $keys
		}
	} else {
		^ecsact config $keys | from json
	}
}

