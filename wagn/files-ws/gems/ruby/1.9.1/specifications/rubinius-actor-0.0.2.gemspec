# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubinius-actor"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Evan Phoenix", "MenTaLguY"]
  s.date = "2011-06-16"
  s.description = "Rubinius's Actor implementation"
  s.email = ["evan@fallingsnow.net", "mental@rydia.net"]
  s.homepage = "http://github.com/rubinius/rubinius-actor"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Rubinius's Actor implementation"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubinius-core-api>, [">= 0"])
    else
      s.add_dependency(%q<rubinius-core-api>, [">= 0"])
    end
  else
    s.add_dependency(%q<rubinius-core-api>, [">= 0"])
  end
end
