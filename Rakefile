require 'rake'
require 'rake/testtask'

task :default => [:test]

# test task
desc 'Run all unit test'
Rake::TestTask.new('test') do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end
