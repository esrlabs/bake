require 'rgen/metamodel_builder'
require 'rgen/metamodel_builder/data_types'

module Bake

  module BakeryModel
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

    class Project < ModelElement
      has_attr 'name', String, :defaultValueLiteral => ""
      has_attr 'config', String, :defaultValueLiteral => ""
    end
    class Exclude < ModelElement
      has_attr 'name', String, :defaultValueLiteral => ""
      has_attr 'config', String, :defaultValueLiteral => ""
    end
    class SubCollection < ModelElement
      has_attr 'name', String, :defaultValueLiteral => ""
    end
    class Collection < ModelElement
      has_attr 'name', String, :defaultValueLiteral => ""
      contains_many 'project', Project, 'collection'
      contains_many 'exclude', Exclude, 'collection'
      contains_many 'collections', SubCollection, 'collection'
    end

    module Project::ClassModule
      def isFound
        @isFound ||= false 
      end
      def found
        @isFound = true 
      end
    end

  end

end
