# frozen_string_literal: true
# typed: true

require_relative '../relationship_type'

module ResourceRegistry
  module RelationshipTypes
    class HasMany
      extend T::Sig

      include RelationshipType

      sig { override.returns(String) }
      def serialize
        'has_many'
      end

      sig { override.params(argument: String, relationship: Relationship).returns(T::Boolean) }
      def should_skip_argument?(argument, relationship)
        argument == relationship.field.to_s.pluralize
      end

      sig { override.returns(T::Boolean) }
      def many_cardinality?
        true
      end

      sig { override.params(relationship: Relationship).returns(Symbol) }
      def reference_id(relationship)
        relationship.primary_key
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
              T.nilable(T.any(T::Hash[String, T.untyped], T::Array[T::Hash[String, T.untyped]]))
            ]
          )
      end
      def shape_result(loaded_data, ids, relationship)
        indexed_res = loaded_data.group_by { |r| r[relationship.field.to_s] }
        ids.map { |id| indexed_res[id] || [] }
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
            rel: Relationship,
            _parent_resource: T.nilable(Resource)
          )
          .returns(T::Hash[Symbol, T.untyped])
      end
      def prepare_dto(dto, ids, rel, _parent_resource)
        dto[rel.field.to_s.pluralize.to_sym] = ids.compact
        dto
      end

      sig { override.returns(Symbol) }
      def relationship_field_name
        field.to_s.pluralize.to_sym
      end
    end
  end
end
