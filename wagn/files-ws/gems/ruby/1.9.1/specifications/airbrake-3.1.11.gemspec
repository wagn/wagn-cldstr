# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "airbrake"
  s.version = "3.1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Airbrake"]
  s.date = "2013-04-11"
  s.email = "support@airbrake.io"
  s.executables = ["airbrake"]
  s.files = ["bin/airbrake"]
  s.homepage = "http://www.airbrake.io"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Send your application errors to our hosted service and reclaim your inbox."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<bourne>, [">= 1.0"])
      s.add_development_dependency(%q<cucumber-rails>, ["~> 1.1.1"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.5.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_development_dependency(%q<sham_rack>, ["~> 1.3.0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<capistrano>, [">= 0"])
      s.add_development_dependency(%q<aruba>, [">= 0"])
      s.add_development_dependency(%q<appraisal>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<girl_friday>, [">= 0"])
      s.add_development_dependency(%q<json-schema>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<bourne>, [">= 1.0"])
      s.add_dependency(%q<cucumber-rails>, ["~> 1.1.1"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5.0"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_dependency(%q<sham_rack>, ["~> 1.3.0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<capistrano>, [">= 0"])
      s.add_dependency(%q<aruba>, [">= 0"])
      s.add_dependency(%q<appraisal>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<girl_friday>, [">= 0"])
      s.add_dependency(%q<json-schema>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<bourne>, [">= 1.0"])
    s.add_dependency(%q<cucumber-rails>, ["~> 1.1.1"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5.0"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    s.add_dependency(%q<sham_rack>, ["~> 1.3.0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<capistrano>, [">= 0"])
    s.add_dependency(%q<aruba>, [">= 0"])
    s.add_dependency(%q<appraisal>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<girl_friday>, [">= 0"])
    s.add_dependency(%q<json-schema>, [">= 0"])
  end
end
