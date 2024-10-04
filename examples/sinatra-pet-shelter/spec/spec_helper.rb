# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../lib/app'
require 'rspec'
require 'rack/test'

RSpec.configure do |_config|
  include Rack::Test::Methods
end
