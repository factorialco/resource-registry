# frozen_string_literal: true
# typed: strict

require 'spec_helper'
require_relative '../../lib/public/versions'

RSpec.describe ResourceRegistry::Versions do
  subject do
    described_class.new(
      versions: [
        ResourceRegistry::Versions::Version.new('2024-01-01'),
        ResourceRegistry::Versions::Version.new('2024-04-01', aliases: 'stable')
      ]
    )
  end

  describe '#find!' do
    it 'returns a version' do
      expect(subject.find!('2024-04-01').to_s).to eq('2024-04-01')
    end

    it 'raises error with wrong name' do
      expect { subject.find!('fake') }.to raise_error(RuntimeError, 'Version \'fake\' not found')
    end
  end

  describe '#find' do
    it 'finds a version from right name' do
      expect(subject.find('2024-04-01').to_s).to eq('2024-04-01')
    end

    it 'does not find a version from wrong name' do
      expect(subject.find('unknown')).to be_nil
    end

    it 'does not find a version from empty header' do
      expect(subject.find(nil)).to be_nil
      expect(subject.find('')).to be_nil
    end

    it 'returns a version with an alias' do
      expect(subject.find!('stable').to_s).to eq('2024-04-01')
    end
  end
end
