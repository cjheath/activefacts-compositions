#
# ActiveFacts Compositions, Metamodel aspect to create a textual summary of a composition and its Composites
# 
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/metamodel"
require "activefacts/compositions/names"
require "activefacts/compositions/constraints"
require "activefacts/generator"

module ActiveFacts
  module Metamodel
    class Composition
      def summary
        classify_constraints
        "Summary of #{name}\n" +
        all_composite.
        sort_by{|composite| composite.mapping.name}.
        flat_map do |composite|
          composite.summary
        end*''
      end
    end

    class Composite
      def summary
        indices = self.all_indices_by_rank

        (
          [mapping.name+"\n"] +
          mapping.
          leaves.
          reject{|leaf| leaf.is_a?(Absorption) && leaf.forward_absorption}.
          flat_map do |leaf|

            # Build a display of the names in this absorption path, with FK and optional indicators
            path_names = leaf.path.map do |component|
                is_mandatory = case component
                  when Indicator
                    false
                  when Absorption
                    component.parent_role.is_mandatory
                  else
                    true
                  end

                if component.all_foreign_key_field.size > 0
                  "[#{component.name}]"
                elsif component.is_a?(Absorption) && component.foreign_key
                  "{#{component.name}}"
                else
                  component.name
                end +
                  (is_mandatory ? '' : '?')
              end*'->' 

            # Build a symbolic representation of the index participation of this leaf
            pos = 0
            indexing = indices.inject([]) do |a, index|
              pos += 1
              if part = index.position_in_index(leaf)
                a << "#{pos}.#{part}"
              end
              a
            end
            if indexing.empty? 
              indexing = '' 
            else
              indexing = "[#{indexing*','}]"
            end

            column_name = leaf.column_name.capwords*' '
            ["\t#{path_names}#{indexing} as #{column_name.inspect}\n"] +
            leaf.all_leaf_constraint.map{|leaf_constraint| "\t\t### #{leaf_constraint.leaf_constraint.describe}\n"}.sort
          end +
          all_local_constraint.map do |local_constraint|
            "\t### #{local_constraint.local_constraint.describe}\n"
          end.sort +
          all_spanning_constraint.map do |spanning_constraint|
            "### #{spanning_constraint.spanning_constraint.describe}\n"
          end.sort

        )*''
      end
    end
  end

  module Generators
    class Summary
      def self.options
        {
        }
      end

      def initialize composition, options = {}
        @composition = composition
        @options = options
      end

      def generate
        @composition.summary
      end
    end
    publish_generator Summary
  end
end
