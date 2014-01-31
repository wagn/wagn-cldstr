# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wagn"
  s.version = "1.12.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason"]
  s.date = "2014-01-31"
  s.description = "Create dynamic web systems out of wiki-inspired building blocks."
  s.email = ["info@wagn.org"]
  s.executables = ["wagn"]
  s.files = ["bin/wagn"]
  s.homepage = "http://wagn.org"
  s.licenses = ["GPL"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Wagn: team-driven websites"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.2.16"])
      s.add_runtime_dependency(%q<smartname>, ["= 0.2.3"])
      s.add_runtime_dependency(%q<htmlentities>, ["~> 4.3"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.3"])
      s.add_runtime_dependency(%q<paperclip>, ["~> 2.8"])
      s.add_runtime_dependency(%q<rmagick>, ["~> 2.13"])
      s.add_runtime_dependency(%q<recaptcha>, ["~> 0.3"])
      s.add_runtime_dependency(%q<xmlscan>, ["~> 0.3"])
      s.add_runtime_dependency(%q<rubyzip>, ["~> 1.0"])
      s.add_runtime_dependency(%q<airbrake>, ["~> 3.1"])
      s.add_runtime_dependency(%q<coderay>, ["~> 1.0"])
      s.add_runtime_dependency(%q<sass>, ["~> 3.2"])
    else
      s.add_dependency(%q<rails>, ["~> 3.2.16"])
      s.add_dependency(%q<smartname>, ["= 0.2.3"])
      s.add_dependency(%q<htmlentities>, ["~> 4.3"])
      s.add_dependency(%q<uuid>, ["~> 2.3"])
      s.add_dependency(%q<paperclip>, ["~> 2.8"])
      s.add_dependency(%q<rmagick>, ["~> 2.13"])
      s.add_dependency(%q<recaptcha>, ["~> 0.3"])
      s.add_dependency(%q<xmlscan>, ["~> 0.3"])
      s.add_dependency(%q<rubyzip>, ["~> 1.0"])
      s.add_dependency(%q<airbrake>, ["~> 3.1"])
      s.add_dependency(%q<coderay>, ["~> 1.0"])
      s.add_dependency(%q<sass>, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.2.16"])
    s.add_dependency(%q<smartname>, ["= 0.2.3"])
    s.add_dependency(%q<htmlentities>, ["~> 4.3"])
    s.add_dependency(%q<uuid>, ["~> 2.3"])
    s.add_dependency(%q<paperclip>, ["~> 2.8"])
    s.add_dependency(%q<rmagick>, ["~> 2.13"])
    s.add_dependency(%q<recaptcha>, ["~> 0.3"])
    s.add_dependency(%q<xmlscan>, ["~> 0.3"])
    s.add_dependency(%q<rubyzip>, ["~> 1.0"])
    s.add_dependency(%q<airbrake>, ["~> 3.1"])
    s.add_dependency(%q<coderay>, ["~> 1.0"])
    s.add_dependency(%q<sass>, ["~> 3.2"])
  end
end
