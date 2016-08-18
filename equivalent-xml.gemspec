Gem::Specification.new do |s|
  s.name = %q{equivalent-xml}
  s.version = '1.0.0'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael B. Klein"]
  s.description = %q{Compares two XML Nodes (Documents, etc.) for certain semantic equivalencies. 
    Currently written for Nokogiri and Oga, but with an eye toward adding more XML libraries}
  s.email = %q{mbklein@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "lib/equivalent-xml.rb",
    "lib/equivalent-xml/rspec_matchers.rb"
  ]
  s.homepage = %q{http://github.com/mbklein/equivalent-xml}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Easy equivalency tests for Ruby XML}
  s.test_files = [
    "spec/equivalent-xml_spec.rb"
  ]

  s.add_development_dependency(%q<nokogiri>, [">= 1.4.3"])
  s.add_development_dependency(%q<oga>)
  s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
  s.add_development_dependency(%q<simplecov>)
  s.add_development_dependency(%q<rspec>, [">= 1.2.4"])
  s.add_development_dependency(%q<rake>, [">= 0.9.0"])
  s.add_development_dependency(%q<rdoc>, [">= 3.12"])
end
