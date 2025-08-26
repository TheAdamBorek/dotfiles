class PurgeCommand
  def initialize(merged = false)
    @merged = merged
  end

  def merged
    PurgeCommand.new(true)
  end

  def run
    command = "git branch" 
    if @merged 
      command += " --merged"
    end
    command += " | grep -Ev \"(\\*|master|development|testflight|crashlytics|develop|#{current_branch})\" | xargs -n 1 git branch -D"
    system(command)
  end

  private
  def current_branch
    `git name-rev --name-only HEAD`.strip
      .gsub('/', '\/')
  end
end

flags = ARGV.join(" ")
command = PurgeCommand.new
if !flags.include? "--all"
  command = command.merged
end
command.run

