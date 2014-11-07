require 'rgen/metamodel_builder'
require 'rgen/metamodel_builder/data_types'

module Cxxproject

  module AliasModel
    extend RGen::MetamodelBuilder::ModuleExtension

    class ModelElement < RGen::MetamodelBuilder::MMBase
      abstract
      has_attr 'line_number', Integer do
        annotation :details => {'internal' => 'true'}
      end
      has_attr 'file_name', String do
        annotation :details => {'internal' => 'true'}
      end
    end

    class Alias < ModelElement
      has_attr 'hdd_name', String, :defaultValueLiteral => ""
      has_attr 'logical_name', String, :defaultValueLiteral => ""
    end
    class Aliases < ModelElement
      contains_many 'alias', Alias, 'aliases'
    end

  end

end
