# frozen_string_literal: true
# typed: false

require "spec_helper"
require_relative "../../lib/resource_registry/relationship"

RSpec.describe ResourceRegistry::Relationship do
  describe "#load" do
    let(:params) do
      {
        "name" => "test",
        "type" => "has_one",
        "field" => :test,
        "resource_id" => :test,
        "optional" => true,
        "primary_key" => :test
      }
    end

    subject { described_class.load(params) }

    it { expect(subject).to be_a(described_class) }

    context "when the spec is not valid" do
      let(:params) { { "type" => "has_one" } }

      it "raises an error" do
        expect { subject }.to raise_error(
          ResourceRegistry::RelationshipType::InvalidRelationshipSpec
        )
      end
    end

    # TODO: Check how to test this
    xcontext "with a custom type" do
      let(:type) { "policy_resolution" }
      let(:params) do
        {
          "name" => "test",
          "type" => type,
          "field" => :test,
          "resource_id" => :test,
          "optional" => true,
          "policies" => []
        }
      end

      it { expect(subject).to be_a(described_class) }
    end
  end
end
