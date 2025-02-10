# typed: strict

module ResourceRegistry
  module RelationshipType
    extend T::Sig
    extend T::Helpers

    InvalidRelationshipSpec = Class.new(StandardError)

    abstract!

    # This enables `is_a?` check type to sorbet
    requires_ancestor { Object }

    ResultShape =
      T.type_alias do
        T::Array[
          T.nilable(
            T.any(
              T::Hash[String, T.untyped],
              T::Array[T::Hash[String, T.untyped]]
            )
          )
        ]
      end

    sig { params(spec: T::Hash[String, T.untyped]).void }
    def initialize(spec)
      @spec = spec
      validate_spec!
    end

    sig { abstract.returns(String) }
    def serialize
    end

    sig do
      abstract
        .params(argument: String, relationship: Relationship)
        .returns(T::Boolean)
    end
    def should_skip_argument?(argument, relationship)
    end

    sig { abstract.returns(T::Boolean) }
    def many_cardinality?
    end

    # The field defined to resolve the other side of the relationship, it can be field or primary_key
    sig { abstract.params(relationship: Relationship).returns(Symbol) }
    def reference_id(relationship)
    end

    sig do
      abstract
        .params(
          loaded_data: T::Array[T::Hash[String, T.untyped]],
          ids: T.untyped, # FIXME
          relationship: Relationship
        )
        .returns(ResultShape)
    end
    def shape_result(loaded_data, ids, relationship)
    end

    sig { abstract.returns(Integer) }
    def complexity
    end

    sig { returns(T::Boolean) }
    def forward_entities?
      false
    end

    sig { returns(T::Boolean) }
    # TODO: doc
    def forward_selected_fields?
      false
    end

    sig do
      abstract
        .params(
          dto: T::Hash[Symbol, T.untyped],
          ids: T::Array[T.any(String, Integer)],
          rel: Relationship,
          parent_resource: T.nilable(Resource)
        )
        .returns(T::Hash[Symbol, T.untyped])
    end
    def prepare_dto(dto, ids, rel, parent_resource)
    end

    sig { returns(T::Array[T::Hash[String, T.untyped]]) }
    def nested_fields
      []
    end

    sig { returns(String) }
    def name
      @spec["name"]
    end

    sig { returns(Symbol) }
    def resource_id
      @spec["resource_id"]&.to_sym
    end

    sig { returns(Symbol) }
    def field
      @spec["field"]&.to_sym
    end

    sig { returns(Symbol) }
    def primary_key
      @spec["primary_key"]&.to_sym
    end

    sig do
      overridable
        .params(read_dto: T.nilable(T.class_of(T::Struct)))
        .returns(T::Boolean)
    end
    def valid_relationship_field?(read_dto)
      return true unless relationship_field_name

      !!read_dto&.props&.keys&.include?(T.must(relationship_field_name))
    end

    sig { overridable.returns(T.nilable(Symbol)) }
    def relationship_field_name
    end

    private

    sig { void }
    def validate_spec!
      errors = []
      errors << "name is required" unless @spec["name"]
      errors << "resource_id is required" unless @spec["resource_id"]
      errors << "field is required" unless @spec["field"]
      errors << "primary_key is required" unless @spec["primary_key"]
      errors << "name must be a string" unless @spec["name"].is_a?(String)

      return if errors.empty?

      Kernel.raise InvalidRelationshipSpec,
                   "The given relationship spec is not valid: #{errors.join(", ")}. The spec is: #{@spec}"
    end
  end
end
