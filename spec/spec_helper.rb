if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
end
require 'rspec'
require 'support/models'
require 'act_as_page_extractor'
require 'byebug'
