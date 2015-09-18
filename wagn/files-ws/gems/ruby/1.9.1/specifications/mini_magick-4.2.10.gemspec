# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mini_magick"
  s.version = "4.2.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Corey Johnson", "Hampton Catlin", "Peter Kieltyka", "James Miller", "Thiago Fernandes Massa", "Janko Marohni\u{107}"]
  s.date = "2015-08-08"
  s.description = "Manipulate images with minimal use of memory via ImageMagick / GraphicsMagick"
  s.email = ["probablycorey@gmail.com", "hcatlin@gmail.com", "peter@nulayer.com", "bensie@gmail.com", "thiagown@gmail.com", "janko.marohnic@gmail.com"]
  s.homepage = "https://github.com/minimagick/minimagick"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.requirements = ["You must have ImageMagick or GraphicsMagick installed"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Manipulate images with minimal use of memory via ImageMagick / GraphicsMagick"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_development_dependency(%q<posix-spawn>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_dependency(%q<posix-spawn>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.1.0"])
    s.add_dependency(%q<posix-spawn>, [">= 0"])
  end
end
