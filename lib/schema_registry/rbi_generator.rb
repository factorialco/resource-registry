# typed: strict

require 'rbi'

module SchemaRegistry
  class RbiGenerator
    extend T::Sig

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    # https://github.com/Shopify/rbi/blob/main/lib/rbi/model.rb
    sig { returns(String) }
    def string
      rbi =
        RBI::File.new(strictness: 'strong') do |file|
          file << RBI::Module.new(schema.namespace.camelize) do |ns_module|
            ns_module << RBI::Module.new('Schemas') do |mod|
              mod << RBI::Module.new(schema.schema_module_name) do |schema_mod|
                append_content(schema_mod)
              end
            end
          end
        end

      rbi.string
    end

    private

    sig { params(schema_mod: T.untyped).void }
    def append_content(schema_mod)
      schema_mod << RBI::Extend.new('T::Sig')
      schema_mod << RBI::Extend.new('T::Helpers')
      # Adds the `interface!` helper call
      schema_mod << RBI::Helper.new('interface')

      schema.properties.each do |prop|
        schema_mod << RBI::Method.new(prop.name) do |method|
          method.sigs << RBI::Sig.new(return_type: to_rbi_type(prop), is_abstract: true)
        end
      end
    end

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(prop: Property).returns(String) }
    def to_rbi_type(prop)
      types = prop.types.map(&:sorbet_type)

      rbi_type = (types.length > 1 ? "T.any(#{prop.types.join(', ')})" : T.must(types.first))

      rbi_type = "T.nilable(#{rbi_type})" if prop.nilable?

      rbi_type
    end
  end
end
