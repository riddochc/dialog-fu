require 'yard'
require 'rake/testtask'
require_relative './lib/dialog.rb'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

desc "Builds the gem"
task :gem do
  sh "gem build dialog-fu.gemspec"
end

desc "Installs the gem"
task :install => :gem do
  sh "gem install dialog-fu-#{Dialog::VERSION}.gem"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end

task :default => [:test]
