require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the userstamp plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the userstamp plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Userstamp'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('Readme.rdoc', 'CHANGELOG', 'LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  project_name = 'userstamp'
  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "This Rails plugin extends ActiveRecord::Base to add automatic updating of created_by and updated_by attributes of your models in much the same way that the ActiveRecord::Timestamp module updates created_(at/on) and updated_(at/on) attributes."
    gem.email = "delynn@gmail.com"
    gem.homepage = "http://github.com/delynn/#{project_name}"
    gem.authors = ["DeLynn Berry"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end