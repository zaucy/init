def gac [] { git add .; git commit }
def "gac typo" [] { git add .; git commit -m "fix: typo" }

def gap [] { git add -N .; git commit -p }

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

export def-env "ghpr" [$query = ""] {
	let prs = (gh search prs $query --author=zaucy --state=open --visibility=public --json=title,repository,number | from json | each {|item| {
		title: $item.title,
		repository: $item.repository.nameWithOwner,
		id: $item.number,
	}})

	if ($prs | length) == 0 {
		print $"(ansi rb)Cannot find any pr with search '($query)'";
		return;
	}

	let pr = if ($prs | length) > 1 {
		$prs | input list -f 'select pr'
	} else {
		$prs | get 0
	}

	if $pr == "" {
		return;
	}

	let pr_dir = ($"~/projects/($pr.repository)" | path expand);

	if not ($pr_dir | path exists) {
		mkdir $pr_dir
	}

	if not ($"($pr_dir)/.git" | path exists) {
		gh repo clone $pr.repository $pr_dir
	}

	cd $pr_dir;

	gh pr checkout $pr.id
}
