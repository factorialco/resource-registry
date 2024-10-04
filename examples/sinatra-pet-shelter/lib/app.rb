# frozen_string_literal: true

require 'sinatra'
require 'sinatra/multi_route'
require 'resource_registry'

require 'sinatra/reloader' if development?

# Main entrypoint of the application
class App < Sinatra::Base
  register Sinatra::MultiRoute

  resources = ResourceRegistry::Registry.new.resources

  resources.each do |resource|
    route :get, "/#{resource}" do
      content_type :json
      { data: [] }.to_json
    end
  end
end
