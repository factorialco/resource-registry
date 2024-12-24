# typed: false

require "spec_helper"
require_relative "../../../lib/resource_registry/capabilities/capability_config"

class DummyCapability < T::Struct
  include ResourceRegistry::Capabilities::CapabilityConfig

  def self.key
    :dummy_capability
  end
end

RSpec.describe ResourceRegistry::Capabilities::CapabilityConfig do
  let(:schema) do
    SchemaRegistry::Schema.new(
      name: "dummy",
      namespace: "dummies",
      properties: [
        SchemaRegistry::Property.new(
          name: "foo",
          types: [SchemaRegistry::PropertyType::String],
          required: true
        )
      ]
    )
  end
  let(:capabilities) { { dummy_capability: DummyCapability.new } }
  let(:resource) do
    ResourceRegistry::Resource.new(
      repository_raw: DummyRepo.to_s,
      capabilities:,
      verbs: {
      },
      schema:
    )
  end

  it "should return resource's capability" do
    expect(DummyCapability.resource_capability?(resource:)).to be true
    expect(DummyCapability.resource_capability(resource:)).to be_a(DummyCapability)
    expect(DummyCapability.resource_capability!(resource:)).to be_a(DummyCapability)
  end

  context 'without the capability' do
    let(:capabilities) { {} }

    it "should return resource's capability" do
      expect(DummyCapability.resource_capability?(resource:)).to be false
      expect(DummyCapability.resource_capability(resource:)).to be_nil
    end
  end
end


