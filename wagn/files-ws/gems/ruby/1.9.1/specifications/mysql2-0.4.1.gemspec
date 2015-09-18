# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mysql2"
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez", "Aaron Stone"]
  s.date = "2015-09-16"
  s.email = ["seniorlopez@gmail.com", "aaron@serendipity.cx"]
  s.extensions = ["ext/mysql2/extconf.rb"]
  s.files = ["ext/mysql2/extconf.rb"]
  s.homepage = "http://github.com/brianmario/mysql2"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "A simple, fast Mysql library for Ruby, binding to libmysql"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
