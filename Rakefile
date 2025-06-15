# Rakefile
# frozen_string_literal: true

require 'bundler/gem_tasks'      # provides build, install, release, etc.
require 'rspec/core/rake_task'   # hook up RSpec

# Define the spec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

# Default task: run specs
task default: :spec
