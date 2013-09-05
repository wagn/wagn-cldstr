# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jquerymobile-rails"
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kurt Robert Rudolph"]
  s.date = "2012-07-18"
  s.description = "This gem incorporates jQueryMobile into the assets of your Rails application."
  s.email = ["jQueryMobile-Rails.RubyGems@RudyIndustries.com"]
  s.homepage = "http://RudyIndustries.GitHub.com/jquerymobile-rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "jQueryMobile! For Rails! So Great."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
  end
end
