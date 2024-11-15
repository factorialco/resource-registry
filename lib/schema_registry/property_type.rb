# typed: strict

module SchemaRegistry
  extend T::Sig

  class PropertyType < T::Enum
    extend T::Sig

    enums do
      # Basic types
      String = new
      Number = new
      Integer = new
      BigInteger = new
      Object = new
      Array = new
      Boolean = new
      Null = new

      # String format specializations
      DateTime = new
      Time = new
      Date = new
      Duration = new
      Email = new
      Uri = new
      Regex = new

      # Other
      File = new
    end

    sig { returns(T.nilable(::String)) }
    # rubocop:disable Metrics/CyclomaticComplexity
    def sorbet_type
      case self
      when String
        "String"
      when Number
        "Float"
      when Integer, BigInteger
        "Integer"
      when Object
        "T::Hash[Symbol, T.untyped]"
      when Array
        "T::Array[T.untyped]"
      when Boolean
        "T::Boolean"
      when Null
        "NilClass"
      when DateTime, Time
        "Time"
      when Date
        "Date"
      when Duration
        "ActiveSupport::Duration"
      when Email
        "Mail::Address"
      when Uri
        "URI::Generic"
      when Regex
        "Regexp"
      when File
        "ActionDispatch::Http::UploadedFile"
      else
        T.absurd(self)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
