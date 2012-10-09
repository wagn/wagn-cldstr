
# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'xmlscan/version'

VERSION = XMLScan::VERSION # File.exist?('VERSION') ? File.read('VERSION') : ""

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

begin
  include XMLScan
    require 'jeweler'
    Jeweler::Tasks.new do |gem|
      gem.name = 'xmlscan'
      gem.version = XMLScan::VERSION
      gem.license = "MIT"
      gem.summary = "The fastest XML parser written in 100% pure Ruby."
      gem.email = "gerryg@inbox.com"
      gem.homepage = "http://github.com/GerryG/xmlformat/"
      gem.description = "The fastest XML parser written in 100% pure Ruby."
      gem.authors = ["UENO Katsuhiro <katsu@blue.sky.or.jp>"]
      gem.files = FileList[
        '[A-Z]*',
        '*.rb',
        'lib/**/*.rb',
        'spec/**/*.rb' ].to_a
      gem.test_files = Dir.glob('spec/*_spec.rb')
      gem.has_rdoc = true
      gem.extra_rdoc_files = [ "README.rdoc", "CHANGES" ]
      gem.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
    end
rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "xmlscan #{VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
