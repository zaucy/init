def "nu-complete bazel build-targets" [] {
	let completions = (bzlq targets "" | lines | each {|it| $it | from json | rename -c {label: value} } | prepend {value: "//...", description: "all targets"});
	
	{
		completions: $completions,
		options: {
			case_sensitive: false,
			positional: false,
			should_sort: false,
			completion_algorithm: "prefix",
		}
	}
}

def "nu-complete bazel run-targets" [] {
	let completions = (bzlq targets --run-only "" | lines | each {|it| $it | from json | rename -c {label: value} });
	
	{
		completions: $completions,
		options: {
			case_sensitive: false,
			positional: false,
			should_sort: false,
			completion_algorithm: "prefix",
		}
	}
}

def "nu-complete bazel test-targets" [] {
	let completions = (bzlq targets --test-only "" | lines | each {|it| $it | from json | rename -c {label: value} } | prepend {value: "//...", description: "all targets"});
	
	{
		completions: $completions,
		options: {
			case_sensitive: false,
			positional: false,
			should_sort: false,
			completion_algorithm: "prefix",
		}
	}
}

export extern "bazel build" [
	...targets: string@"nu-complete bazel build-targets",
]

export extern "bazel run" [
	target: string@"nu-complete bazel run-targets",
]

export extern "bazel test" [
	...targets: string@"nu-complete bazel test-targets",
]

export extern "bazel-dbg" [
	target: string@"nu-complete bazel run-targets",
]
