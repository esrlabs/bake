require 'rtext/serializer'

module RText
  class Serializer
    alias :old_serialize_values :serialize_values
    def serialize_values(element, feature)
      return nil unless element.eIsSet(feature.name)
      old_serialize_values(element, feature)
    end
  end
end
