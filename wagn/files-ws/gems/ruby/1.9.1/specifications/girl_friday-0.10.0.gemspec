# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "girl_friday"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Perham"]
  s.date = "2012-08-02"
  s.description = "Background processing, simplified"
  s.email = ["mperham@gmail.com"]
  s.homepage = "http://github.com/mperham/girl_friday"
  s.require_paths = ["lib"]
  s.rubyforge_project = "girl_friday"
  s.rubygems_version = "1.8.23"
  s.summary = "Background processing, simplified"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<connection_pool>, ["~> 0.9.0"])
      s.add_development_dependency(%q<sinatra>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<connection_pool>, ["~> 0.9.0"])
      s.add_dependency(%q<sinatra>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<connection_pool>, ["~> 0.9.0"])
    s.add_dependency(%q<sinatra>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
