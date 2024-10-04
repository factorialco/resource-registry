# frozen_string_literal: true
# typed: true

class Repository
  extend T::Sig

  include ::ResourceRegistry::Repositories::Base
  extend RuntimeGeneric

  sig { returns(T.untyped) }
  def self.entity
    # Dirty hack to make Tapioca work with `tapioca dsl` command, our
    # RuntimeGeneric is not compatible with it
    return if defined?(Tapioca)

    T.unsafe(const_get(:Entity)).inner_type[:fixed]
  end

  # Migrate to RR gem
  sig(:final) { returns(String) }
  def self.namespace
    namespace = to_s.split('::Repositories').first
    return T.must(namespace).sub('::', '') if namespace != to_s

    T.must(to_s.split('::').first)
  end
end
