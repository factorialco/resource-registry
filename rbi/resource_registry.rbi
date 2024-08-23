# typed: true

module Maybe
  sig do
    type_parameters(:Value)
      .params(value: T.all(BasicObject, T.type_parameter(:Value)))
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Value))])
  end
  # Creates an instance containing the specified value.
  # Necessary to make this work with sorbet-coerce
  def self.new(value); end
end
