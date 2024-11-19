# frozen_string_literal: true
# typed: false

require "spec_helper"
require_relative "../../lib/public/relationship"

RSpec.describe ResourceRegistry::Relationship do
  describe "#load" do
    let(:type) { ResourceRegistry::RelationshipTypes::HasOne.new({}) }
    let(:params) do
      {
        "name" => "test",
        "type" => type.serialize,
        "field" => :test,
        "resource_id" => :test,
        "optional" => true
      }
    end

    subject { described_class.load(params) }

    it { expect(subject).to be_a(described_class) }

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
