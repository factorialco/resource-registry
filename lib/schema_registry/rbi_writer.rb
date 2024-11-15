# typed: strict

module SchemaRegistry
  class RbiWriter
    extend T::Sig
    OUTPUT = T.let("sorbet/rbi/factorial/", String)

    sig { params(schema: Schema, rbi: String).void }
    def initialize(schema:, rbi:)
      @schema = schema
      @rbi = rbi
    end

    sig { void }
    def call
      file_uri =
        File.join(
          OUTPUT,
          schema.namespace.underscore,
          "#{schema.slug.underscore}.rbi"
        )
      FileUtils.mkdir_p(File.dirname(file_uri))

      File.write(file_uri, rbi)
    end

    private

    sig { returns(Schema) }
    attr_reader :schema

    sig { returns(String) }
    attr_reader :rbi
  end
end
