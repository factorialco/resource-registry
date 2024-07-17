# frozen_string_literal: true
# typed: strict

require_relative 'capability_config'

module ResourceRegistry
  module Capabilities
    class Reports < T::Struct
      extend T::Sig
      include CapabilityConfig

      const :time_dimension, T.nilable(String)
      const :time_dimension_end, T.nilable(String)
      const :category_label, T.nilable(String)
      const :expiration_date, T.nilable(Date)

      sig { override.returns(Symbol) }
      def key
        :reports
      end
    end
  end
end
