# typed: false

require 'spec_helper'
require_relative '../lib/public/capability_factory'

RSpec.describe ResourceRegistry::CapabilityFactory do
  let(:capability) { described_class }
  let(:capability_config) { ResourceRegistry::Capabilities::Reports.new(time_dimension: 'foo') }

  describe '#dump' do
    it { expect(capability.dump(capability_config)).to include_json(time_dimension: 'foo') }
  end

  describe '#load' do
    let(:data) { { 'key' => 'reports', :time_dimension => 'bar' } }
    let(:data_2) { { 'key' => 'rest', 'is_public' => true } }

    it do
      cap = capability.load(data)
      expect(described_class.dump(cap)).to include_json(time_dimension: 'bar')
    end

    it 'loads rest data with provided public value' do
      cap = capability.load(data_2)
      expect(cap.is_public).to be true
    end

    it 'loads graphql data with provided included_in_root_query value' do
      cap = capability.load({ 'key' => 'graphql', 'included_in_root_query' => false })
      expect(cap.included_in_root_query).to be false
    end
  end
end
