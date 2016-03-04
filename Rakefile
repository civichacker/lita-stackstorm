require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "github_changelog_generator/task"

RSpec::Core::RakeTask.new(:spec)



GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.since_tag = 'v0.4.0'
  config.future_release = 'v0.5.0'
end

task default: :spec
