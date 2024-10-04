# frozen_string_literal: true

require 'spec_helper'

describe App do
  let(:app) { App.new }

  context 'GET /' do
    let(:response) { get '/' }

    it 'returns 200 OK' do
      expect(response.status).to eq 200
    end
  end
end
