# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rubycritic/rake_task'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end

RubyCritic::RakeTask.new do |task|
  # # Name of RubyCritic task. Defaults to :rubycritic.
  # task.name    = 'something_special'

  # # Glob pattern to match source files. Defaults to FileList['.'].
  task.paths = FileList['lib/**/*.rb']

  # # You can pass all the options here in that are shown by "rubycritic -h" except for
  # # "-p / --path" since that is set separately. Defaults to ''.
  # task.options = '--mode-ci --format json'
  # # task.options = '--no-browser'

  # # Defaults to false
  task.verbose = true
end

RSpec::Core::RakeTask.new(:spec)

# task default: %w[rubocop:auto_correct rubycritic spec]
task default: %w[rubocop:auto_correct spec]
