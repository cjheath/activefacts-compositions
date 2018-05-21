#
# ActiveFacts Compositions, Metamodel aspect to look for validation errors in a composition
#
# Quite a few constraints are not enforced during the construction of a composition.
# This method does a post-validation to ensure that everything looks ok.
# 
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/metamodel"
require "activefacts/metamodel/validate/composition"
require "activefacts/compositions/compositor"
require "activefacts/generator"

module ActiveFacts
  module Generators
    class Validate
      def self.options
        {
        }
      end

      def self.compatibility
        [nil, nil]
      end
  
      def initialize constellation, composition, options = {}
        @constellation = constellation
        @composition = composition
        @options = options
      end

      def generate &report
        if !report
          trace.enable 'composition_validator'
          report ||= proc do |component, problem|
            trace :composition_validator, "!!PROBLEM!! #{component.inspect}: #{problem}"
            debugger if trace :composition_validator_debug
            component
          end
        end

        Array(@composition).
        each do |c|
          c.validate(&report)
        end
        nil
      end
    end
    publish_generator Validate, "Perform a thorough validation to check that a compositor is working correctly"
  end
end
