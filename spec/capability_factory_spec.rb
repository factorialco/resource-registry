# frozen_string_literal: true
# typed: false

require "spec_helper"
require_relative "./dummy_capability"
require_relative "../lib/resource_registry/capability_factory"

RSpec.describe ResourceRegistry::CapabilityFactory do
  let(:capability) { described_class }
  let(:capability_config) { DummyCapability.new(time_dimension: "foo") }

  describe "#dump" do
    it do
      expect(capability.dump(capability_config)).to include_json(
        time_dimension: "foo"
      )
    end
  end

  describe "#load" do
    let(:data) { { "key" => "dummy_capability", :time_dimension => "bar" } }

    it do
      cap =
        capability.load(
          data,
          capabilities: {
            dummy_capability: DummyCapability
          }
        )
      expect(described_class.dump(cap)).to include_json(time_dimension: "bar")
    end
  end
end
