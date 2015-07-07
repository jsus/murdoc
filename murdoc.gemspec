# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'murdoc/version'

Gem::Specification.new do |spec|
  spec.name = "murdoc"
  spec.version = Murdoc::VERSION

  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=
  spec.require_paths = ["lib"]
  spec.authors = ["Mark Abramov"]
  spec.date = "2015-07-06"
  spec.description = "Annotated documentation generator, see README.md for details"
  spec.email = "markizko@gmail.com"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.homepage = "http://github.com/markiz/murdoc"
  spec.licenses = ["Public Domain"]
  spec.rubygems_version = "2.4.5"
  spec.summary = "Annotated documentation generator"

  spec.add_dependency 'kramdown', '~> 0.13'
  spec.add_dependency 'haml', '~> 3.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.4.0'
  spec.add_development_dependency 'rdiscount', '~> 1.6.5'
end

