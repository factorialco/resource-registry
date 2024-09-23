# frozen_string_literal: true

require 'spec_helper'
require_relative 'app'

describe App do
  let(:app) { App.new }

  context 'GET /' do
    let(:response) { get '/members' }

    it 'returns 200 OK' do
      expect(response.status).to eq 200
    end
  end
end
