# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mysql2"
  s.version = "0.3.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = "2013-07-17"
  s.email = "seniorlopez@gmail.com"
  s.extensions = ["ext/mysql2/extconf.rb"]
  s.files = ["ext/mysql2/extconf.rb"]
  s.homepage = "http://github.com/brianmario/mysql2"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "A simple, fast Mysql library for Ruby, binding to libmysql"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<eventmachine>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.8.1"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.3"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.8.1"])
      s.add_dependency(%q<rake>, ["~> 0.9.3"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.8.1"])
    s.add_dependency(%q<rake>, ["~> 0.9.3"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
  end
end
