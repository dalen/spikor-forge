require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'

task :default do
  sh %{rake -T}
end

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern ='spec/{unit,integration}/**/*_spec.rb'
  t.fail_on_error = true
end

