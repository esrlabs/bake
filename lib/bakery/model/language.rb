require 'bake/model/metamodel'
require 'rtext/language'

module Bake

  BakeryLanguage =
  RText::Language.new(BakeryModel.ecore,
    :feature_provider => proc {|c|
      RGen::Serializer::OppositeReferenceFilter.call(c.eAllStructuralFeatures).reject {|f|
        f.eAnnotations.any? {|a|
          a.details.any? {|d| d.key == 'internal' && d.value == 'true'}
        }
      }
    },
    :unlabled_arguments => proc {|c|
      ["name"]
    },
    :line_number_attribute => "line_number",
    :file_name_attribute => "file_name"
  )

end
