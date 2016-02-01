#
# ActiveFacts Compositions, Produce a summary of a composition
# 
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/metamodel"
require "activefacts/compositions/names"

module ActiveFacts
  module Metamodel
    class Composition
      def summary
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
	  mapping.leaves.flat_map do |leaf|

	    # Build a display of the names in this absorption path, with FK and optional indicators
	    path_names = leaf.path.map do |component|
		is_mandatory = case component
		  when ActiveFacts::Metamodel::Indicator
		    false
		  when ActiveFacts::Metamodel::Absorption
		    component.parent_role.is_mandatory
		  else
		    true
		  end

		if component.is_a?(ActiveFacts::Metamodel::Absorption) && component.foreign_key
		  "[#{component.name}]"
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

	    column_name = ActiveFacts::Compositions::Names.new(leaf).names.capwords*' '
	    ["\t#{path_names}#{indexing} as #{column_name.inspect}\n"]
	  end
	)*''
      end
    end
  end
end
