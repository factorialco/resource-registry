# typed: false

require 'spec_helper' # you are forced to load the whole context for this :/
require_relative '../lib/schema_registry/maybe' # unit tests are currently not possible

RSpec.describe Maybe do
  let(:present) { Maybe.from(6) }
  let(:nilable) { Maybe.from(nil) }
  let(:absent) { Maybe.empty }

  describe '#strip' do
    let(:input) { { present: Maybe.from(6), absent: Maybe.empty, always: 5 } }

    subject { Maybe.strip(input) }

    it 'removes all absent values, unwraps present `Maybe`s' do
      expect(subject).to match({ present: 6, always: 5 })
    end
  end

  describe '#present?' do
    subject { maybe.present? }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#absent?' do
    subject { maybe.absent? }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns true' do
        expect(subject).to be true
      end
    end
  end

  describe '#or_default' do
    subject { maybe.or_default(default) }

    let(:default) { '1337' }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns the contained value' do
        expect(subject).to be 6
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns the contained value' do
        expect(subject).to be_nil
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns the default value' do
        expect(subject).to be default
      end
    end
  end

  describe '#when_present' do
    subject { maybe.when_present { |v| (v || 0) + 1 } }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns the value returned from the block' do
        expect(subject).to be 7
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns the value returned from the block' do
        expect(subject).to be 1
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#when_absent' do
    subject { maybe.when_absent { 1 + 1 } }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns the value returned from the block' do
        expect(subject).to be 2
      end
    end
  end

  describe '#filter' do
    subject { maybe.filter { |_e| filter_output } }

    context 'when the filter returns false' do
      let(:filter_output) { false }

      context 'and a value is present' do
        let(:maybe) { present }

        it 'returns an empty instance' do
          expect(subject.absent?).to be true
        end
      end

      context 'and a `nil` value is present' do
        let(:maybe) { nilable }

        it 'returns an empty instance' do
          expect(subject.absent?).to be true
        end
      end

      context 'and a value is not present' do
        let(:maybe) { absent }

        it 'returns an empty instance' do
          expect(subject.absent?).to be true
        end
      end
    end

    context 'when the filter returns true' do
      let(:filter_output) { true }

      context 'and a value is present' do
        let(:maybe) { present }

        it 'returns the same instance' do
          expect(subject).to be maybe
        end
      end

      context 'and a `nil` value is present' do
        let(:maybe) { nilable }

        it 'returns the same instance' do
          expect(subject).to be maybe
        end
      end

      context 'and a value is not present' do
        let(:maybe) { absent }

        it 'returns the same instance' do
          expect(subject).to be maybe
        end
      end
    end
  end

  describe '#map' do
    subject { maybe.map { |e| (e || 0) + 1 } }

    context 'when a value is present' do
      let(:maybe) { present }

      it 'returns an instance containing the result of the block' do
        expect(subject).to eq Maybe.from(7)
      end
    end

    context 'when a `nil` value is present' do
      let(:maybe) { nilable }

      it 'returns an instance containing the result of the block' do
        expect(subject).to eq Maybe.from(1)
      end
    end

    context 'when a value is not present' do
      let(:maybe) { absent }

      it 'returns the same instance' do
        expect(subject).to be maybe
      end
    end
  end

  describe '#==' do
    subject { first == second }

    context 'when both have values' do
      context 'and the values are the same' do
        let(:first) { Maybe.from('Potato') }
        let(:second) { Maybe.from('Potato') }

        it('returns true') { expect(subject).to be true }
      end

      context 'and the values are different' do
        let(:first) { Maybe.from('Tomato') }
        let(:second) { Maybe.from('Carrot') }

        it('returns false') { expect(subject).to be false }
      end
    end

    context 'when only one has values' do
      let(:first) { Maybe.from('Apricot') }
      let(:second) { Maybe.empty }

      it('returns false') { expect(subject).to be false }
    end

    context 'when neither has values' do
      let(:first) { Maybe.empty }
      let(:second) { Maybe.empty }

      it('returns true') { expect(subject).to be true }
    end
  end
end
