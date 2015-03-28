# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bootstrap-kaminari-views"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matenia Rossides"]
  s.date = "2014-09-06"
  s.description = "Bootstrap-ify pagination with Kaminari - Compatible with Bootstrap 2.x, 3.x"
  s.email = ["matenia@gmail.com"]
  s.homepage = "http://github.com/matenia/bootstrap-kaminari-views"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Bootstrap-ify pagination with Kaminari"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.1"])
      s.add_runtime_dependency(%q<kaminari>, [">= 0.13"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.1"])
      s.add_dependency(%q<kaminari>, [">= 0.13"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.1"])
    s.add_dependency(%q<kaminari>, [">= 0.13"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
