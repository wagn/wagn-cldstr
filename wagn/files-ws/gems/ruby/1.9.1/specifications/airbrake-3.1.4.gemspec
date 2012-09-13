# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "airbrake"
  s.version = "3.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Airbrake"]
  s.date = "2012-09-12"
  s.email = "support@airbrake.io"
  s.homepage = "http://www.airbrake.io"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Send your application errors to our hosted service and reclaim your inbox."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<girl_friday>, [">= 0"])
      s.add_development_dependency(%q<actionpack>, ["~> 2.3.8"])
      s.add_development_dependency(%q<activerecord>, ["~> 2.3.8"])
      s.add_development_dependency(%q<activesupport>, ["~> 2.3.8"])
      s.add_development_dependency(%q<mocha>, ["= 0.10.5"])
      s.add_development_dependency(%q<bourne>, [">= 1.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.10.6"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_development_dependency(%q<sham_rack>, ["~> 1.3.0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<capistrano>, ["~> 2.8.0"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-test>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<girl_friday>, [">= 0"])
      s.add_dependency(%q<actionpack>, ["~> 2.3.8"])
      s.add_dependency(%q<activerecord>, ["~> 2.3.8"])
      s.add_dependency(%q<activesupport>, ["~> 2.3.8"])
      s.add_dependency(%q<mocha>, ["= 0.10.5"])
      s.add_dependency(%q<bourne>, [">= 1.0"])
      s.add_dependency(%q<cucumber>, ["~> 0.10.6"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_dependency(%q<sham_rack>, ["~> 1.3.0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<capistrano>, ["~> 2.8.0"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-test>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<girl_friday>, [">= 0"])
    s.add_dependency(%q<actionpack>, ["~> 2.3.8"])
    s.add_dependency(%q<activerecord>, ["~> 2.3.8"])
    s.add_dependency(%q<activesupport>, ["~> 2.3.8"])
    s.add_dependency(%q<mocha>, ["= 0.10.5"])
    s.add_dependency(%q<bourne>, [">= 1.0"])
    s.add_dependency(%q<cucumber>, ["~> 0.10.6"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    s.add_dependency(%q<sham_rack>, ["~> 1.3.0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<capistrano>, ["~> 2.8.0"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-test>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end
