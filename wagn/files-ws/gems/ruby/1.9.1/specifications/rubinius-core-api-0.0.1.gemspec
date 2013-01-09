# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubinius-core-api"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Oliver Nutter"]
  s.date = "2011-06-16"
  s.description = "Cross-impl versions of interesting Rubinius core classes"
  s.email = ["headius@headius.com"]
  s.homepage = "http://github.com/rubinius/rubinius-core-api"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Cross-impl versions of interesting Rubinius core classes"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
