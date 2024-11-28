# frozen_string_literal: true
# typed: false

require "spec_helper"
require_relative "../../lib/resource_registry/versions"

RSpec.describe ResourceRegistry::Versions do
  subject { described_class.new(versions: versions) }

  let(:versions) do
    [
      ResourceRegistry::Versions::Version.new("2024-01-01"),
      ResourceRegistry::Versions::Version.new("2024-04-01", aliases: "stable")
    ]
  end

  describe "#find!" do
    it "returns a version" do
      expect(subject.find!("2024-04-01").to_s).to eq("2024-04-01")
    end

    it "raises error with wrong name" do
      expect { subject.find!("fake") }.to raise_error(
        RuntimeError,
        'Version \'fake\' not found'
      )
    end
  end

  describe "#find" do
    it "finds a version from right name" do
      expect(subject.find("2024-04-01").to_s).to eq("2024-04-01")
    end

    it "does not find a version from wrong name" do
      expect(subject.find("unknown")).to be_nil
    end

    it "does not find a version from empty header" do
      expect(subject.find(nil)).to be_nil
      expect(subject.find("")).to be_nil
    end

    it "returns a version with an alias" do
      expect(subject.find!("stable").to_s).to eq("2024-04-01")
    end
  end

  describe "#find_next" do
    context "when given an old version" do
      it "returns the following version" do
        expect(subject.find_next("2024-01-01").to_s).to eq("2024-04-01")
      end

      context "when given a version object" do
        it "returns the following version" do
          version = subject.find!("2024-01-01")

          expect(subject.find_next(version).to_s).to eq("2024-04-01")
        end
      end
    end

    context "when given the last version" do
      it "does not returns a version" do
        expect(subject.find_next("2024-04-01")).to be_nil
      end

      context "when given a version object" do
        it "does not returns a version" do
          version = subject.find!("2024-04-01")

          expect(subject.find_next(version)).to be_nil
        end
      end
    end

    context "when given a random value" do
      it "does not returns a version" do
        expect { subject.find_next("2025-04-01") }.to raise_error(
          RuntimeError,
          'Version \'2025-04-01\' not found'
        )
      end
    end

    context "when given a list of unsorted versions" do
      let(:versions) do
        [
          ResourceRegistry::Versions::Version.new(
            "2024-03-01",
            aliases: "stable"
          ),
          ResourceRegistry::Versions::Version.new(
            "2024-04-01",
            aliases: "deprecated"
          ),
          ResourceRegistry::Versions::Version.new("2024-02-01")
        ]
      end

      it "orders and returns the following version" do
        expect(subject.find_next("2024-02-01").to_s).to eq("2024-03-01")
      end
    end
  end

  describe "#in_range" do
    let(:versions) do
      [
        ResourceRegistry::Versions::Version.new("2024-01-01"),
        ResourceRegistry::Versions::Version.new("2024-04-28"),
        ResourceRegistry::Versions::Version.new("2024-09-20"),
        ResourceRegistry::Versions::Version.new("2025-01-09")
      ]
    end

    it "filters versions by >= from and <= to" do
      expect(subject.in_range("2024-04-28", "2024-09-20").count).to eq(2)
    end

    context "with only from" do
      it "filters versions by >= from" do
        expect(subject.in_range("2024-04-28", nil).count).to eq(3)
      end
    end

    context "with only to" do
      it "filters versions by <= to" do
        expect(subject.in_range(nil, "2024-09-20").count).to eq(3)
      end
    end

    context "with unexisting version" do
      it "raises error with wrong name" do
        expect { subject.in_range("2022-01-01", "2022-01-01") }.to raise_error(
          RuntimeError,
          'Version \'2022-01-01\' not found'
        )
      end
    end

    context "without from and to" do
      it "does not apply any filter" do
        expect(subject.in_range(nil, nil).count).to eq(4)
      end
    end
  end
end
