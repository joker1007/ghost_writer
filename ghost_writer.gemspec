# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ghost_writer/version'

Gem::Specification.new do |gem|
  gem.name          = "ghost_writer"
  gem.version       = GhostWriter::VERSION
  gem.authors       = ["joker1007"]
  gem.email         = ["kakyoin.hierophant@gmail.com"]
  gem.description   = %q{Generate API examples from params and response of controller specs}
  gem.summary       = %q{Generate API examples from params and response of controller specs}
  gem.homepage      = "https://github.com/joker1007/ghost_writer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", ">= 3.0.0"
  gem.add_dependency "rspec-rails", "~> 2.11"
  gem.add_dependency "trollop"

  gem.add_development_dependency "rspec", "~> 2.12"
  gem.add_development_dependency 'rake', ['>= 0']
  gem.add_development_dependency 'rails', ['~> 3.2.9']
end
