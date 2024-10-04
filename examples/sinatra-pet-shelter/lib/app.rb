# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?

# Main entrypoint of the application
class App < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end
