#
# ActiveFacts Compositions, Metamodel aspect to build compacted column names for (leaf) Components
#
#	Compresses the names arising from absorption paths into usable column names
#
# Copyright (c) 2016 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions"

module ActiveFacts
  module Metamodel
    class Component
      def column_name
	column_path = path[1..-1]
	prev_words = []
	String::Words.new(
	  column_path.
	  inject([]) do |na, member|
	    is_absorption = member.is_a?(Absorption)
	    is_type_inheritance = is_absorption && member.parent_role.fact_type.is_a?(TypeInheritance)
	    fact_type = is_absorption && member.parent_role.fact_type

	    # If the parent object identifies the child via this absorption, skip it.
	    if member != column_path.first and
		is_absorption and
		!is_type_inheritance and
		member.parent_role.base_role.is_identifying
	      trace :names, "Skipping #{member}, identifies non-initial object"
	      next na
	    end

	    words = member.name.words

	    if na.size > 0 && is_type_inheritance
	      # When traversing type inheritances, keep the subtype name, not the supertype names as well:
	      if member.child_role != fact_type.subtype_role
		trace :names, "Skipping supertype #{member}"
		next na
	      end
	      trace :names, "Eliding supertype in #{member}"
	      prev_words.size.times{na.pop}

	    elsif member.parent && member != column_path.first && is_absorption && member.child_role.base_role.is_identifying
	      # When Xyz is followed by identifying XyzID (even if we skipped the Xyz), truncate that to just ID
	      pnames = member.parent.name.words
	      if pnames == words[0, pnames.size]
		pnames.size.times do
		  pnames.shift
		  words.shift
		end
	      end
	    end

	    # If the reference is to the single identifying role of the object_type making the reference,
	    # strip the object_type name from the start of the reference role
	    if na.size > 0 and
		is_absorption and
		member.child_role.base_role.is_identifying and
		(et = member.object_type).is_a?(EntityType) and
		et.preferred_identifier.role_sequence.all_role_ref.size == 0 and
		et.name.downcase == words[0][0...et.name.size].downcase
	      trace :columns, "truncating transitive identifying role #{words.inspect}"
	      words[0] = words[0][et.name.size..-1]
	      words.shift if words[0] == ''
	    end

	    prev_words = words
	    na += words.to_a
	  end.elide_repeated_subsequences do |a, b|
	    if a.is_a?(Array)
	      a.map{|e| e.downcase} == b.map{|e| e.downcase}
	    else
	      a.downcase == b.downcase
	    end
	  end
	)
      end
    end
  end
end
