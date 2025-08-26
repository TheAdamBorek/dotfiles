git_flags = ARGV.join(" ")
branches = %x(git branch | grep \\*)
current_branch = branches.split[1, branches.length - 1].first
`git push origin #{current_branch} #{git_flags}`
