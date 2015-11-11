require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
    private
      MM = ActiveFacts::Metamodel

    public
      def generate
	super

	trace :binary, "Constructing Binary Composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    composite = @constellation.Composite(mapping, composition: @composition)

	    if object_type.is_a?(MM::ValueType)
	      # A ValueType that's made into a Composite needs a ValueField injected
	      @constellation.ValueField(:new, parent: mapping, name: "Value", object_type: object_type)
	    end

	    next_rank = 0
	    by_rank = mapping.all_member.to_a.sort_by(&:rank_key)
	    trace :binary, "#{object_type.name} contains in rank order" do
	      by_rank.each do |member|
		rank_key = member.rank_key

		case rank_key[0]
		when MM::Component::RANK_MULTIPLE,
		    MM::Component::RANK_SUBTYPE
		  member.retract
		  next

		when MM::Component::RANK_SUPER
		  absorb_key member

		when MM::Component::RANK_MANDATORY
		when MM::Component::RANK_NON_MANDATORY
		  child_unique = member.child_role.is_unique
		  parent_unique = member.parent_role.is_unique
		  if child_unique && parent_unique
		    # Decide which end to keep?
		  end

		  absorb_key member
		end

		trace :binary, "#{next_rank}: #{member.inspect} (RANK #{member.rank_key.inspect})"
		member.ordinal = next_rank
		next_rank += 1
	      end
	    end
	  end
	end

	trace :composition, "Full binary composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    mapping.show_trace 
	  end
	end

      end
    end
  end
end
