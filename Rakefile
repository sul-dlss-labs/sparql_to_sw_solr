require 'bundler'
require 'rake'

task default: :ci

desc 'run continuous integration suite (tests, coverage, docs)'
task ci: [:spec, :rubocop]

begin
  require 'rspec/core/rake_task'
  desc 'Run RSpec'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'Run RSpec'
  task :spec do
    abort 'Please install the rspec gem to run tests.'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Run rubocop'
  task :rubocop do
    abort 'Please install the rubocop gem to run rubocop.'
  end
end
