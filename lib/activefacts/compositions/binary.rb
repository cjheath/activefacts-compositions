require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
    private
      MM = ActiveFacts::Metamodel

    public
      def generate
	super

	trace :composition, "Constructing Binary Composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    composite = @constellation.Composite(mapping, composition: @composition)

	    if object_type.is_a?(MM::ValueType)
	      # A ValueType that's made into a Composite needs a ValueField injected
	      @constellation.ValueField(:new, parent: mapping, name: "Value", object_type: object_type)
	    end

	    next_rank = 0
	    by_rank = mapping.all_member.to_a.sort_by(&:rank_key)
	    trace :composition, "#{object_type.name} contains in rank order" do
	      by_rank.each do |member|
		trace :composition, "#{member.inspect} (RANK #{member.rank_key.inspect})"
	      end
	    end

=begin
	    by_rank.each do |member|

	      rank_key = member.rank_key
	      case member
	      when MM::Indicator
		# Nothing to do here
	      when MM::Absorption
		fact_type = member.parent_role.fact_type
		child_unique = member.child_role.is_unique
		parent_unique = member.parent_role.is_unique
		case
		when !member.child_role.is_unique
		  # manifold fact type: retract
		when fact_type.is_a?(MM::TypeInheritance)
		  if member.parent_role == fact_type.subtype
		    # This object has a supertype member.child_role.object_type
		  else
		    # This object has a subtype member.child_role.object_type
		  end
		when child_unique && parent_unique
		  # Other one-to-one fact type
		when true
		  # Existential fact type
		when mapping.child_role.is_mandatory
		  # Mandatory fact type
		else
		  # Optional fact type
		end
	      else
		raise "Primitive mapping for #{mapping.object_type.name} has invalid content type #{member.class}"
	      end

	      member.rank = next_rank
	      next_rank += 1
	    end
=end

	  end
	end
      end

    end
  end

  module Metamodel
    class Component
      # The ranking key of a component indicates its importance to its parent:
      # Ranking assigns a total order, but is computed in groups:
      RANK_SUPER = 0
      # Supertypes are group 0,
      #	  with the identifying supertype having position 0, others alphabetical
      RANK_IDENT = 1
      # Identifying components (absorptions, indicator) are group 1,
      #	  in order of their appearance in the identifying PresenceConstraint
      RANK_VALUE = 1
      # A ValueField is group 1
      RANK_INJECTION = 2
      # Injections are group 2,
      #	  in alphabetical order
      RANK_DISCRIMINATOR = 3
      # Discriminator components are group 3,
      #	  in alphabetical order
      RANK_FOREIGN = 4
      #	REVISIT: Foreign key components are group 4
      RANK_INDICATOR = 5
      # Indicators are group 5
      #	  in alphabetical order
      RANK_MANDATORY = 6
      RANK_NON_MANDATORY = 7
      RANK_MANIFOLD = 8
      # Absorptions are group 6 if unique mandatory, group 7 if unique, group 8 if manifold
      RANK_SUBTYPE = 9
      # Subtypes are group 9
      RANK_SCOPING = 10
      #	  in alphabetical order
      # Scoping is group 9
      def rank_key
	parent_pi = parent &&
	  parent.object_type.is_a?(EntityType) &&
	  parent.object_type.preferred_identifier

	case self
	when Indicator
	  if parent_pi &&
	      (position = parent_pi.role_sequence.all_role_ref_in_order.map(&:role).index(role))
	    [RANK_IDENT, position]     # An identifying unary
	  else
	    [RANK_INDICATOR, name || role.role_name || role.fact_type.default_reading]	      # A non-identifying unary
	  end

	when Discriminator
	  [RANK_DISCRIMINATOR, name || object_type.name]

	when ValueField
	  [RANK_IDENT]

	when Injection
	  [RANK_INJECTION, name || object_type.name]	      # REVISIT: A different sub-key for ranking may be needed

	when Absorption
	  if is_type_inheritance
	    # We are traversing a type inheritance fact type. Is this object_type the subtype or supertype?
	    if is_supertype_absorption
	      # What's the rank of this supertype?
	      tis = parent_role.object_type.all_type_inheritance_as_subtype.sort_by{|ti| ti.provides_identification ? '' : ti.supertype.name }
	      [RANK_SUPER, child_role.fact_type.provides_identification ? 0 : 1+tis.index(parent_role.fact_type)]
	    else
	      # What's the rank of this subtype?
	      tis = parent_role.object_type.all_type_inheritance_as_supertype.sort_by{|ti| ti.subtype.name }
	      [RANK_SUBTYPE, tis.index(parent_role.fact_type)]
	    end
	  elsif parent_pi &&
	      (position = parent_pi.role_sequence.all_role_ref_in_order.map(&:role).index(child_role))
	    [RANK_IDENT, position]
	  else
	    if parent_role.is_unique
	      [parent_role.is_mandatory ? RANK_MANDATORY : RANK_NON_MANDATORY, name || child_role.role_name || object_type.name]
	    else
	      [RANK_MANIFOLD, name || child_role.role_name || object_type.name]
	    end
	  end

	when Scoping
	  [RANK_SCOPING, name || object_type.name]

	else
	  raise "unexpected Component type in Component#rank_key"
	end
      end
    end
  end
end
