#
# Cookbook: poise-service-aix
# License: Apache 2.0
#
# Copyright 2015, Noah Kantrowitz
# Copyright 2015-2016, Bloomberg Finance L.P.
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'poise_service/aix/version'

Gem::Specification.new do |spec|
  spec.name = 'poise-service-aix'
  spec.version = PoiseService::AIX::VERSION
  spec.authors = ['John Bellone', 'Shahul Khajamohideen']
  spec.email = %w{jbellone@bloomberg.net skhajamohid1@bloomberg.net}
  spec.description = 'An AIX provider for poise-service.'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/bloomberg-cookbooks/poise-service-aix'
  spec.license = 'Apache 2.0'

  spec.files = `git ls-files`.split($RS)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{lib}

  spec.add_dependency 'halite', '~> 1.0'
  spec.add_dependency 'poise', '~> 2.0'
  spec.add_dependency 'poise-service', '~> 1.0'

  spec.add_development_dependency 'poise-boiler', '~> 1.0'

  spec.metadata['halite_dependencies'] = 'aix ~> 2.0'
end
