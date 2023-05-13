def gac [] { git add .; git commit }
def "gac typo" [] { git add .; git commit -m "fix: typo" }

def "git-prune-branches" [] {
	^git fetch -p;
	let branches = (^git branch -vv | find 'gone');

	if ($branches | length) == 0 {
		print "No branches to prune";
		return;
	}
	
	$branches | each {|b|
		let branch_name = ($b | ansi strip | str trim | split row ' ' --number=2 | get 0);
		print $branch_name;
	};

	print "";

	let should_delete = (input "Delete these branches? [Y/n] ");
	
	if ($should_delete | str capitalize) == "Y" or ($should_delete | str length) == 0 {
		$branches | each {|b|
			let branch_name = ($b | ansi strip | str trim | split row ' ' --number=2 | get 0);
			^git branch -D $branch_name;
		};
	} else {
		print "Aborted (user input)";
	}
}

