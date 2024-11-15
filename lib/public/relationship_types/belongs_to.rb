# frozen_string_literal: true
# typed: strict

require_relative "../relationship_type"

module ResourceRegistry
  module RelationshipTypes
    class BelongsTo
      extend T::Sig

      include RelationshipType

      sig { override.returns(String) }
      def serialize
        "belongs_to"
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
        false
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
            relationship: Relationship
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
      def shape_result(loaded_data, ids, relationship)
        indexed_res =
          loaded_data.index_by do |resource|
            resource[relationship.primary_key.to_s]
          end
        ids.map { |id| indexed_res[id] }
      end

      sig { override.returns(Integer) }
      def complexity
        5
      end

      sig do
        override
          .params(
            dto: T::Hash[Symbol, T.untyped],
            ids: T::Array[T.any(String, Integer)],
            rel: Relationship,
            _parent_resource: T.nilable(Resource)
          )
          .returns(T::Hash[Symbol, T.untyped])
      end
      def prepare_dto(dto, ids, rel, _parent_resource)
        dto[rel.primary_key.to_s.pluralize.to_sym] = ids.compact
        dto
      end

      sig { override.returns(Symbol) }
      def relationship_field_name
        primary_key.to_s.pluralize.to_sym
      end
    end
  end
end
