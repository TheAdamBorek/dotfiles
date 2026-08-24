def pending_changes?
  !`git status --porcelain`.empty?
end
branch_name = ARGV.length > 0 ? ARGV[0] : 'develop'
pending_changes = pending_changes?

if pending_changes
  puts "Stashing changes..."
  `git stash`
end

sh_result = %x(git branch | grep \\*)
current_branch = sh_result.split[1, sh_result.length - 1].first
`git checkout #{branch_name}` 
`git pull origin #{branch_name}`
`git checkout #{current_branch}`

if pending_changes
  puts "Poping stash..."
  `git stash pop`
end
