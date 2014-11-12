require 'bake/model/metamodel'

require 'rtext/language'



module Bake

  class Idp
    def call(e,unused)
      e.respond_to?(:ident) ? e.ident() : nil # IdentifierProvider.qualified_name(e)
    end
  end


  Language =
  RText::Language.new(Metamodel.ecore,
    :feature_provider => proc {|c|
      RGen::Serializer::OppositeReferenceFilter.call(c.eAllStructuralFeatures).reject {|f|
        f.eAnnotations.any? {|a|
          a.details.any? {|d| d.key == 'internal' && d.value == 'true'}
        }
      }
    },
    :unlabled_arguments => proc {|c|
      if c.name == "Compiler" or c.name == "CompilerAdaptions" 
        ["ctype"]
      elsif c.name == "Define"
        ["str"]
      elsif c.name == "Flags" or c.name == "LibPostfixFlags" or c.name == "LibPrefixFlags"
        ["overwrite"]
      elsif c.name == "UserLibrary"
        ["lib"]
      elsif c.name == "DefaultToolchain"
        ["basedOn"]
      elsif c.name == "Description"
        ["text"]
      else
        ["name"]
      end
    },
    :identifier_provider => Idp.new,
    :line_number_attribute => "line_number",
    :file_name_attribute => "file_name",
    :fragment_ref_attribute => "fragment_ref"#,
  )

end
