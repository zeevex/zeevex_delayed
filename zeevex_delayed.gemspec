# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zeevex_delayed/version"

Gem::Specification.new do |s|
  s.name        = "zeevex_delayed"
  s.version     = ZeevexDelayed::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Sanders"]
  s.email       = ["robert@zeevex.com"]
  s.homepage    = ""
  s.summary     = %q{Basic and per-thread promise classes.}
  s.description = %q{This gem provides a couple of classes useful for deferred computation.}

  s.rubyforge_project = "zeevex_delayed"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'zeevex_proxy'

  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'rake'
end
