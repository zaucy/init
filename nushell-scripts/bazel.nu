def "nu-complete bazel targets" [] {
	^bzlq targets | lines | each {|it| $it | from json | rename -c [label value] }
}

def "nu-complete bazel run-targets" [] {
	^bzlq targets --run-only | lines | each {|it| $it | from json | rename -c [label value] }
}

def "nu-complete bazel test-targets" [] {
	^bzlq targets --test-only | lines | each {|it| $it | from json | rename -c [label value] }
}

export extern "bazel build" [
	...targets: string@"nu-complete bazel targets",
]

export extern "bazel run" [
	target: string@"nu-complete bazel run-targets",
]

export extern "bazel test" [
	...targets: string@"nu-complete bazel test-targets",
]

