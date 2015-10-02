# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activefacts/compositions/version'

Gem::Specification.new do |spec|
  spec.name          = "activefacts-compositions"
  spec.version       = ActiveFacts::Compositions::VERSION
  spec.authors       = ["Clifford Heath"]
  spec.email         = ["clifford.heath@gmail.com"]

  spec.summary       = %q{Create and represent composite schemas, schema transforms and data transforms over a fact-based model}
  spec.description   = %q{Create and represent composite schemas, schema transforms and data transforms over a fact-based model}
  spec.homepage      = "https://github.com/cjheath/activefacts-compositions"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency(%q<activefacts-metamodel>, [">= 1.7.0", "~> 1.7"])
end
