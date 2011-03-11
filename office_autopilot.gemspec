# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "office_autopilot/version"

Gem::Specification.new do |s|

  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('webmock', '~> 1.6')

  s.add_runtime_dependency('httparty', '~> 0.7')
  s.add_runtime_dependency('builder', '~> 3.0')
  s.add_runtime_dependency('nokogiri', '~> 1.4')


  s.name        = "office_autopilot"
  s.version     = OfficeAutopilot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "office_autopilot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
