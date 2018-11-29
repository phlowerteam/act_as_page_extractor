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

  spec.add_development_dependency 'bundler',   '~> 1.3'
  spec.add_development_dependency 'rake',      '~> 0'
  spec.add_development_dependency 'byebug',    '~> 0'
  spec.add_development_dependency 'rspec',     '~> 0'
  spec.add_development_dependency 'simplecov', '~> 0'

  spec.add_runtime_dependency 'activerecord',     '~> 4.1'
  spec.add_runtime_dependency 'awesome_print',    '~> 1.1', '>= 1.1.0'
  spec.add_runtime_dependency 'docsplit',         '~> 0'                  # API for OpenOffice jodconverter (any to pdf)
  spec.add_runtime_dependency 'pdf_utils',        '~> 0'                  # getting text from pdf
  spec.add_runtime_dependency 'prawn',            '~> 0.7.1'              # need for pdf_utils
  spec.add_runtime_dependency 'pdf-reader',       '~> 1.4.0', '>= 1.4.0'  # need for pdf_utils
  spec.add_runtime_dependency 'total_compressor', '~> 0'                  # decompressing files
  spec.add_runtime_dependency 'filesize',         '~> 0'                  # pretty size of file
end
