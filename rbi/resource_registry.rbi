module ResourceRegistry::Repositories::Base
  Entity = type_member {{ entity: T::Struct }}
end

module Maybe
  Value = type_member(:out) { { upper: BasicObject } }
end

