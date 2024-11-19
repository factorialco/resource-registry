# frozen_string_literal: true

require "sinatra"
require "sinatra/multi_route"
require "resource_registry"

require "sinatra/reloader" if development?
require "pry"

require_relative "repository"

Dir[File.expand_path("lib/resources/*.rb")].each { |f| require_relative(f) }

# Main entrypoint of the application
class App < Sinatra::Base
  register Sinatra::MultiRoute

  registry, =
    ResourceRegistry::Initializer.new(repository_base_klass: Repository).call
  resources = registry.fetch_all

  resources.each do |id, resource|
    next unless resource.verbs.include?(:read)

    route :get, "/#{resource.collection_name}" do
      content_type :json
      { data: [] }.to_json
    end
  end
end
