# frozen_string_literal: true

require 'spec_helper'

describe App do
  let(:app) { App.new }

  context 'GET /dogs' do
    let(:response) { get '/dogs' }

    it 'returns 200 OK' do
      expect(response.status).to eq 200
    end
  end
end
