# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rmagick"
  s.version = "2.13.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Hunter", "Omer Bar-or", "Benjamin Thomas", "Moncef Maiza"]
  s.date = "2014-11-25"
  s.description = "RMagick is an interface between Ruby and ImageMagick."
  s.email = "github@benjaminfleischer.com"
  s.extensions = ["ext/RMagick/extconf.rb"]
  s.files = ["ext/RMagick/extconf.rb"]
  s.homepage = "https://github.com/gemhome/rmagick"
  s.licenses = ["MIT"]
  s.post_install_message = "Please report any bugs. See https://github.com/gemhome/rmagick/compare/RMagick_2-13-2...master and https://github.com/rmagick/rmagick/issues/18"
  s.require_paths = ["lib", "ext"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.5")
  s.requirements = ["ImageMagick 6.4.9 or later"]
  s.rubyforge_project = "rmagick"
  s.rubygems_version = "1.8.23.2"
  s.summary = "Ruby binding to ImageMagick"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
    else
      s.add_dependency(%q<rake-compiler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake-compiler>, [">= 0"])
  end
end
