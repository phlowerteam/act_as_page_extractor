unless ENV['SKIP_COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter 'vendor'
  end
  SimpleCov.minimum_coverage 100
end

require 'rspec'
require 'support/models'
require 'act_as_page_extractor'
require 'byebug'
