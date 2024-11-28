# frozen_string_literal: true
# typed: strict

require "date"
require "bigdecimal"
require_relative "property_type"
require_relative "maybe"
require_relative "../resource_registry/versions/version"

module SchemaRegistry
  class Property < T::Struct
    extend T::Sig

    ValueType =
      T.type_alias do
        T.nilable(
          T.any(
            T::Boolean,
            Integer,
            Float,
            BigDecimal,
            String,
            Date,
            Time,
            DateTime,
            T::Array[T.untyped],
            T::Hash[String, T.untyped],
            Maybe[T.untyped],
            ResourceRegistry::Versions::Version
          )
        )
      end

    const :name, String
    const :types, T::Array[PropertyType]
    const :type_name, T.nilable(String)
    const :items, T::Array[Property], default: []
    const :properties, T::Array[Property], default: []
    const :description, T.nilable(String), default: nil
    const :resolver, T.nilable(T::Hash[Symbol, String]), default: nil
    const :resolvable, T::Boolean, default: false
    const :deprecated, T::Boolean, default: false
    const :deprecated_on, T.nilable(Date), default: nil
    const :example, T.nilable(ValueType), default: nil
    const :enum_values, T.nilable(T::Array[String]), default: []
    const :required, T::Boolean
    const :default, ValueType, default: nil
    const :serialization_groups, T::Set[Symbol], default: Set[]

    sig { returns(T::Boolean) }
    def deprecated?
      return false if deprecated_on.blank?

      T.must(deprecated_on) < Time.zone.today
    end

    sig { returns(T::Boolean) }
    def null?
      @types == [PropertyType::Null]
    end

    sig { returns(T::Array[PropertyType]) }
    def types
      return @types if null?

      @types - [PropertyType::Null]
    end

    sig { returns(T::Boolean) }
    def nilable?
      return false if null?

      @types.include?(PropertyType::Null)
    end

    sig { returns(T::Boolean) }
    def required?
      required
    end

    sig { returns(T::Boolean) }
    def value_object?
      !!type_name.to_s.split("::").any?("ValueObjects")
    end

    sig { params(group: Symbol).returns(T::Boolean) }
    def serialization_group?(group)
      serialization_groups.include?(group)
    end
  end
end
