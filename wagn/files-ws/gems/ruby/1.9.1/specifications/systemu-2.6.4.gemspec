# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "systemu"
  s.version = "2.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ara T. Howard"]
  s.date = "2014-03-04"
  s.description = "universal capture of stdout and stderr and handling of child process pid for windows, *nix, etc."
  s.email = "ara.t.howard@gmail.com"
  s.homepage = "https://github.com/ahoward/systemu"
  s.licenses = ["same as ruby's"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "codeforpeople"
  s.rubygems_version = "1.8.23.2"
  s.summary = "systemu"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
