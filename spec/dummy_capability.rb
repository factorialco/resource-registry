# frozen_string_literal: true
# typed: strict

class DummyCapability < T::Struct
  extend T::Sig

  include ResourceRegistry::Capabilities::CapabilityConfig

  const :time_dimension, T.nilable(String), default: 'day'

  sig { override.returns(Symbol) }
  def self.key
    :dummy_capability
  end
end
