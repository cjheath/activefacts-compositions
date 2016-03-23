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
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.11", "~> 1.11.2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"

  spec.add_development_dependency "activefacts", "~> 1", ">= 1.8"

  spec.add_runtime_dependency("activefacts-api", "~> 1", ">= 1.9.9")
  spec.add_runtime_dependency("activefacts-metamodel", "~> 1", ">= 1.9.6")
  spec.add_runtime_dependency "tracing", "~> 2", ">= 2.0.6"

  spec.add_runtime_dependency "activefacts-cql", "~> 1", ">= 1.8"
end
