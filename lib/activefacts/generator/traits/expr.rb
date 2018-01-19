#
#       ActiveFacts Generator Expression List Traits
#
# Each expression is a string which, evaluated in some context (usu. SQL),
# yields a single value of the specified type (perhaps an array value!)
#
# Copyright (c) 2017 Clifford Heath. Read the LICENSE file.
#
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    class Expression
    private
      MM = ActiveFacts::Metamodel unless const_defined?(:MM)
    public
      attr_reader :type_num       # ActiveFacts::Metamodel::DataType number
      attr_reader :value          # String representation of the expression
      attr_reader :is_mandatory   # false if nullable
      attr_reader :is_array       # the expression returns an array of the specified type

      # Construct an expression that addresses a field from a Metamodel::Component
      def initialize value, type_num, is_mandatory, is_array = false
        @type_num = type_num
        @value = value
        @is_mandatory = is_mandatory
        @is_array = is_array
      end

      def to_s
        value
      end

      def inspect
        "Expression(#{value.inspect}, #{@type_num ? ActiveFacts::Metamodel::DataType::TypeNames[@type_num] : 'unknown'}, #{@is_mandatory ? 'mandatory' : 'nullable'}#{@is_array ? ', array' : ''})"
      end
    end
  end
end
