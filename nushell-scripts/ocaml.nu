def opam-env [] {
  opam env --shell=csh | lines | each {|it| $it | str substring 7..-1 | split row " " -n 2} | each {|it| {$it.0: ($it.1 | str trim -c "'")}} | into record | flatten | get 0
}