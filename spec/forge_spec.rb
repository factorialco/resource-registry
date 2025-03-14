# frozen_string_literal: true
# typed: false

require "spec_helper"
require_relative "./mock_synthesizer"
require_relative "./mock_concept"
require_relative "../lib/forge"
require "fileutils"

RSpec.describe Forge do
  let(:forge) { Forge.new }
  let(:concept) { MockConcept.new }
  let(:synthesizer) { MockSynthesizer.new }

  describe "#forge" do
    before do
      FileUtils.rm_rf(MockSynthesizer::PATH) if Dir.exist?("tmp")

      forge.register_synthesizer(synthesizer)
      FileUtils.mkdir_p("tmp")
    end

    after { FileUtils.rm_rf(MockSynthesizer::PATH) }

    it "forges an artifact" do
      forge.forge(concept)
      expect(File.exist?(MockSynthesizer::PATH)).to be_truthy
      expect(File.read(MockSynthesizer::PATH)).to eq(synthesizer.content)
    end

    it "deletes an artifact" do
      forge.forge(concept)
      expect(File.exist?(MockSynthesizer::PATH)).to be_truthy

      synthesizer.synthesizes = false
      forge.forge(concept)
      expect(File.exist?(MockSynthesizer::PATH)).to be_falsey
    end

    it "rebuilds an artifact" do
      forge.forge(concept)
      initial_path = MockSynthesizer::PATH

      expect(File.exist?(initial_path)).to be_truthy
      expect(File.read(initial_path)).to eq(synthesizer.content)

      synthesizer.content = "A different content"
      forge.forge(concept)

      expect(File.exist?(initial_path)).to be_truthy
      expect(File.exist?(MockSynthesizer::PATH)).to be_truthy
      expect(File.read(MockSynthesizer::PATH)).to eq(synthesizer.content)
    end
  end
end
