# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'act_as_page_extractor/version'

Gem::Specification.new do |spec|
  spec.name          = 'act_as_page_extractor'
  spec.version       = ActAsPageExtractor::VERSION
  spec.authors       = ['PhlowerTeam']
  spec.email         = ['phlowerteam@gmail.com']
  spec.description   = %q{Library (Docsplit wrapper) for text extraction from pdf, doc/x, txt files with OpenOffice}
  spec.summary       = %q{Uses system calls}
  spec.homepage      = 'https://github.com/phlowerteam'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'

  spec.add_runtime_dependency 'activerecord', '~> 4.1'
  spec.add_runtime_dependency 'awesome_print'
  spec.add_runtime_dependency 'docsplit'            # API for OpenOffice jodconverter (any to pdf)
  spec.add_runtime_dependency 'pdf_utils'           # getting text from pdf
  spec.add_runtime_dependency 'prawn', '~>0.7.1'    # need for pdf_utils
  spec.add_runtime_dependency 'pdf-reader'          # need for pdf_utils
  spec.add_runtime_dependency 'total_compressor'    # decompressing files
  spec.add_runtime_dependency 'filesize'            # pretty size of file
end
