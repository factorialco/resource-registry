# frozen_string_literal: true
# typed: strict

class VoidCapability < T::Struct
  extend T::Sig

  include ResourceRegistry::Capabilities::CapabilityConfig

  sig { override.returns(Symbol) }
  def self.key
    :void_capability
  end
end
