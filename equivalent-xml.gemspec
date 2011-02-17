Gem::Specification.new do |s|
  s.name = %q{equivalent-xml}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael B. Klein"]
  s.date = %q{2011-02-17}
  s.description = %q{Compares two XML Nodes (Documents, etc.) for certain semantic equivalencies. 
    Currently written for Nokogiri, but with an eye toward supporting multiple XML libraries}
  s.email = %q{mbklein@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "lib/equivalent-xml.rb"
  ]
  s.homepage = %q{http://github.com/mbklein/equivalent-xml}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Easy equivalency tests for Ruby XML}
  s.test_files = [
    "spec/equvalent-xml_spec.rb"
  ]

  s.add_development_dependency(%q<nokogiri>, [">= 0"])
  s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
  s.add_development_dependency(%q<rcov>, [">= 0"])
  s.add_development_dependency(%q<rspec>, [">= 0"])
end

