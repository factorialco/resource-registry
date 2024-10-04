# frozen_string_literal: true

require_relative '../repository'

class Dog < T::Struct
end

class Dogs < Repository
  extend T::Sig

  Entity = type_member { { fixed: Dog } }
end
