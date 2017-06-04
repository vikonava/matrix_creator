lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matrix_creator/version'

Gem::Specification.new do |spec|
  spec.name          = 'matrix_creator'
  spec.version       = MatrixCreator::VERSION
  spec.authors       = ['Victor Nava']
  spec.email         = ['viko.nava@gmail.com']

  spec.summary       = 'Library to communicate with Matrix Creator'
  spec.description   = 'Abstraction level RubyGem for the MATRIX Creator device
                        to interact with its sensors and interfaces.'
  spec.homepage      = 'https://www.vikonava.com/'
  spec.license       = 'GNU AGPLv3'

  spec.files         = Dir['{config,lib,vendor}/**/*'] + ['README.md']
  spec.require_paths = ['lib']
  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.48'
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.add_dependency 'rbczmq', '~> 1.7'
  spec.add_dependency 'google-protobuf', '~> 3.0'
end
