def "nu-complete zoxide query" [] {
	let completions = (^zoxide query -l --exclude $env.PWD | lines);

	{
		completions: $completions,
		options: {
			case_sensitive: false,
			positional: false,
			should_sort: false,
			completion_algorithm: "fuzzy",
		}
	}
}

