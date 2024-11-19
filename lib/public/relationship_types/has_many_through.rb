# frozen_string_literal: true
# typed: strict

require_relative "../relationship_type"

module ResourceRegistry
  module RelationshipTypes
    class HasManyThrough
      extend T::Sig

      include RelationshipType

      sig { override.returns(String) }
      def serialize
        "has_many_through"
      end

      sig do
        override
          .params(argument: String, relationship: Relationship)
          .returns(T::Boolean)
      end
      def should_skip_argument?(argument, relationship)
        argument == relationship.primary_key.to_s.pluralize
      end

      sig { override.returns(T::Boolean) }
      def many_cardinality?
        true
      end

      sig { override.params(relationship: Relationship).returns(Symbol) }
      def reference_id(relationship)
        relationship.field
      end

      sig do
        override
          .params(
            loaded_data: T::Array[T::Hash[String, T.untyped]],
            ids: T.untyped, # FIXME
            _relationship: Relationship
          )
          .returns(
            T::Array[
              T.nilable(
                T.any(
                  T::Hash[String, T.untyped],
                  T::Array[T::Hash[String, T.untyped]]
                )
              )
            ]
          )
      end
      def shape_result(loaded_data, ids, _relationship)
        ids.map do |many_ids|
          loaded_data.filter { |r| many_ids.include?(r["id"]) }
        end
      end

      sig { override.returns(Integer) }
      def complexity
        10
      end

      sig do
        override
          .params(
            dto: T::Hash[Symbol, T.untyped],
            ids: T::Array[T.any(String, Integer)],
            _rel: Relationship,
            _parent_resource: T.nilable(Resource)
          )
          .returns(T::Hash[Symbol, T.untyped])
      end
      def prepare_dto(dto, ids, _rel, _parent_resource)
        dto[:ids] = ids.flatten.compact.uniq
        dto
      end

      sig { override.returns(Symbol) }
      def relationship_field_name
        :ids
      end
    end
  end
end
