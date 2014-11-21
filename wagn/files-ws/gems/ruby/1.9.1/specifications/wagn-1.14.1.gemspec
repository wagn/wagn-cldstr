# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wagn"
  s.version = "1.14.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason"]
  s.date = "2014-11-21"
  s.description = "a wiki approach to stuctured data, dynamic interaction, and web design"
  s.email = ["info@wagn.org"]
  s.executables = ["wagn"]
  s.files = ["bin/wagn"]
  s.homepage = "http://wagn.org"
  s.licenses = ["GPL"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "2.0.3"
  s.summary = "structured wiki web platform"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["= 3.2.16"])
      s.add_runtime_dependency(%q<smartname>, ["= 0.2.3"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.3"])
      s.add_runtime_dependency(%q<paperclip>, ["~> 2.8"])
      s.add_runtime_dependency(%q<htmlentities>, ["~> 4.3"])
      s.add_runtime_dependency(%q<rmagick>, ["~> 2.13"])
      s.add_runtime_dependency(%q<recaptcha>, ["~> 0.3"])
      s.add_runtime_dependency(%q<coderay>, ["~> 1.0"])
      s.add_runtime_dependency(%q<sass>, ["~> 3.2"])
      s.add_runtime_dependency(%q<coffee-script>, ["~> 2.2"])
      s.add_runtime_dependency(%q<uglifier>, ["~> 2.5"])
      s.add_runtime_dependency(%q<haml>, ["~> 4.0"])
      s.add_runtime_dependency(%q<kaminari>, ["~> 0.16"])
      s.add_runtime_dependency(%q<diffy>, ["~> 3.0"])
      s.add_runtime_dependency(%q<diff-lcs>, ["~> 1.2"])
      s.add_runtime_dependency(%q<airbrake>, ["~> 4.1"])
    else
      s.add_dependency(%q<rails>, ["= 3.2.16"])
      s.add_dependency(%q<smartname>, ["= 0.2.3"])
      s.add_dependency(%q<uuid>, ["~> 2.3"])
      s.add_dependency(%q<paperclip>, ["~> 2.8"])
      s.add_dependency(%q<htmlentities>, ["~> 4.3"])
      s.add_dependency(%q<rmagick>, ["~> 2.13"])
      s.add_dependency(%q<recaptcha>, ["~> 0.3"])
      s.add_dependency(%q<coderay>, ["~> 1.0"])
      s.add_dependency(%q<sass>, ["~> 3.2"])
      s.add_dependency(%q<coffee-script>, ["~> 2.2"])
      s.add_dependency(%q<uglifier>, ["~> 2.5"])
      s.add_dependency(%q<haml>, ["~> 4.0"])
      s.add_dependency(%q<kaminari>, ["~> 0.16"])
      s.add_dependency(%q<diffy>, ["~> 3.0"])
      s.add_dependency(%q<diff-lcs>, ["~> 1.2"])
      s.add_dependency(%q<airbrake>, ["~> 4.1"])
    end
  else
    s.add_dependency(%q<rails>, ["= 3.2.16"])
    s.add_dependency(%q<smartname>, ["= 0.2.3"])
    s.add_dependency(%q<uuid>, ["~> 2.3"])
    s.add_dependency(%q<paperclip>, ["~> 2.8"])
    s.add_dependency(%q<htmlentities>, ["~> 4.3"])
    s.add_dependency(%q<rmagick>, ["~> 2.13"])
    s.add_dependency(%q<recaptcha>, ["~> 0.3"])
    s.add_dependency(%q<coderay>, ["~> 1.0"])
    s.add_dependency(%q<sass>, ["~> 3.2"])
    s.add_dependency(%q<coffee-script>, ["~> 2.2"])
    s.add_dependency(%q<uglifier>, ["~> 2.5"])
    s.add_dependency(%q<haml>, ["~> 4.0"])
    s.add_dependency(%q<kaminari>, ["~> 0.16"])
    s.add_dependency(%q<diffy>, ["~> 3.0"])
    s.add_dependency(%q<diff-lcs>, ["~> 1.2"])
    s.add_dependency(%q<airbrake>, ["~> 4.1"])
  end
end
