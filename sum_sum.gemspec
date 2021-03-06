# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sum_sum/version"

Gem::Specification.new do |s|
  s.name        = "sum_sum"
  s.version     = SumSum::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastian Munz"]
  s.email       = ["sebastian@yo.lk"]
  s.homepage    = "https://github.com/yolk/sum_sum"
  s.summary     = %q{SumSum allows you to generate simple reports on the count of values in hashes.}
  s.description = %q{SumSum allows you to generate simple reports on the count of values in hashes.}

  s.rubyforge_project = "sum_sum"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rspec',       '>= 2.4.0'
  s.add_development_dependency 'guard-rspec', '>=0.1.9'
  s.add_development_dependency 'growl',       '>=1.0.3'
  s.add_development_dependency 'rb-fsevent',  '>=0.3.9'
end