require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Relational < Binary
    private
      MM = ActiveFacts::Metamodel

      # A candidate is a Mapping of an object type which may become a Composition (a table, in relational-speak)
      class Candidate
	attr_reader :mapping, :is_table, :is_tentative

	def initialize mapping
	  @mapping = mapping
	end

	def object_type
	  @mapping.object_type
	end

	def references_from
	  @mapping.all_member.select{|m| m.is_a?(MM::Absorption) && !m.reverse_absorption }
	end
	alias_method :rf, :references_from

	def references_to
	  @mapping.all_member.select{|m| m.is_a?(MM::Absorption) && !m.absorption }
	end
	alias_method :rt, :references_to

	def unique_references
	  @mapping.all_member.select{|m| m.is_a?(MM::Absorption) && m.parent_role.is_unique }
	end

	def has_references
	  @mapping.all_member.select{|m| m.is_a?(MM::Absorption) }
	end

	def definitely_not_table
	  @is_tentative = @is_table = false
	end

	def definitely_table
	  @is_tentative = false
	  @is_table = true
	end

	def probably_not_table
	  @is_tentative = true
	  @is_table = false
	end

	def probably_table
	  @is_tentative = @is_table = true
	end

	def assign_default
	  o = object_type
	  if o.is_separate
	    trace :relational, "#{o.name} is a table because it's declared independent or separate"
	    definitely_table
	    return
	  end

	  case o
	  when MM::ValueType
	    if o.is_auto_assigned
	      trace :relational, "#{o.name} is not a table because it is auto assigned"
	      definitely_not_table
	    elsif references_from.size == 0 and references_to.size > 0 || o.all_value_type_as_supertype.size > 0
	      trace :relational, "#{o.name} is not a table because it has no references to absorb but can be absorbed elsewhere"
	      definitely_not_table
	    else
	      trace :relational, "#{o.name} is a table because it has references to absorb"
	      definitely_table
	    end

	  when MM::EntityType
	    if references_to.empty? and !references_from.detect{|absorption| absorption.parent_role.is_unique && absorption.child_role.is_unique}
	      trace :relational, "#{o.name} is a table because it has nothing to absorb it"
	      definitely_table
	      return
	    end
	    if !o.supertypes.empty?
	      # We know that this entity type is not a separate or partitioned subtype, so a supertype that can absorb us does
	      identifying_fact_type = o.preferred_identifier.role_sequence.all_role_ref.to_a[0].role.fact_type
	      if identifying_fact_type.is_a?(MM::TypeInheritance)
		trace :relational, "#{o.name} is absorbed into supertype #{identifying_fact_type.supertype_role.name}"
		definitely_not_table
	      else
		trace :relational, "Subtype #{o.name} is initially presumed to be a table"
		probably_not_table
	      end
	      return
	    end	# subtype

	    v = nil
	    if references_to.size > 1 and   # Absorbed in more than one place
		o.preferred_identifier.role_sequence.all_role_ref.detect{|rr|
		  (v = rr.role.object_type).is_a?(MM::ValueType) and v.is_auto_assigned
		}
	      trace :relational, "#{o.name} must be a table to support its auto-assigned identifier #{v.name}"
	      definitely_table
	      return
	    end

	    trace :relational, "#{o.name} is initially presumed to be a table"
	    probably_table

	  end	# case
	end

      end

    public
      def generate
	super

	@candidates = @mappings.inject({}){|h,(absorption, mapping)| h[mapping.object_type] = Candidate.new(mapping); h}

	@ca = @candidates.values

	trace :relational, "Setting default assumptions about table/non-table" do
	  @ca.each(&:assign_default)
	end

	optimise_absorption

	delete_reverse_absorptions

	absorb_all_columns

	make_composites

	inject_value_fields

	trace :relational, "Full relational composition" do
	  @composition.all_composite.sort_by{|composite| composite.mapping.name}.each do |composite|
	    composite.mapping.show_trace
	  end
	end
      end

      # Absorb all items which aren't tables (and keys to those which are) recursively
      def absorb_all_columns
	# REVISIT: Incomplete
      end

      def optimise_absorption
	trace :relational, "Optimise Relational Composition" do
	  undecided = @candidates.keys.select{|object_type| @candidates[object_type].is_tentative}
	  pass = 0
	  finalised = []
	  begin
	    pass += 1
	    trace :relational, "Starting optimisation pass #{pass}" do
	      finalised = optimise_absorption_pass(undecided)
	    end
	    trace :relational, "Finalised #{finalised.size} on this pass: #{finalised.map{|f| f.name}*', '}"
	    undecided -= finalised
	  end while !finalised.empty?
	end
      end

      def optimise_absorption_pass undecided
	possible_flips = {}
	undecided.select do |object_type|
	  candidate = @candidates[object_type]
	  trace :relational, "Considering possible status of #{object_type.name}" do

	    # Rule 1: Always absorb an objectified unary into its role player:
	    if (f = object_type.fact_type) && f.all_role.size == 1
	      trace :relational, "Absorb objectified unary #{object_type.name} into #{f.all_role.single.object_type.name}"
	      candidate.definitely_not_table
	      next object_type
	    end

	    # Rule 2: If the preferred_identifier contains one role only, played by an entity type that can absorb us, do that:
	    absorbing_ref = nil
	    if object_type.is_a?(MM::EntityType) and		  # We're an entity type
	      (pi_roles = object_type.preferred_identifier_roles).size == 1 and	  # Our PI has one role
	      pi_roles[0].object_type.is_a?(MM::EntityType) and	  # played by another Entity Type
	      candidate.unique_references.detect do |absorption|
		  next unless absorption.child_role == pi_roles[0] # Not the identifying absorption

		  # Look at the other end; make sure it's a forward absorption:
		  absorption = absorption.reverse_absorption ? absorption.reverse_absorption : absorption.flip!

		  next absorbing_ref = absorption
		end
	      candidate.definitely_not_table
	      trace :relational, "#{object_type.name} is fully absorbed along its sole reference path #{absorbing_ref.inspect}"
	      next object_type
	    end

	    # Rule 3: If there's more than one absorption path and any functional dependencies that can't absorb us, it's a table

	    # Rule 4: If this object can be fully absorbed, do that (might require some flips)

	    # Rule 5: If this object absorbs no non-identifying roles, it's not a table, but is fully absorbed, perhaps in multiple places

	    false   # Otherwise we failed to make a decision about this object type
	  end
	end
      end

      # Remove any multi-valued absorptions:
      def delete_reverse_absorptions
	@mappings.each do |object_type, mapping|
	  mapping.all_member.to_a.		# Avoid problems with deletion from all_member
	  each do |member|
	    next unless member.is_a?(MM::Absorption)
	    member.retract if member.reverse_absorption	# This is the reverse of some absorption
	  end
	  mapping.re_rank
	end
      end

      # After all table/non-table decisions are made, convert Mappings for tables into Composites and retract the rest:
      def make_composites
	@candidates.keys.to_a.each do |object_type|
	  candidate = @candidates[object_type]
	  mapping = candidate.mapping
	  if candidate.is_table
	    composite = @constellation.Composite(mapping, composition: @composition)
	  else
	    mapping.retract
	    @mappings.delete(object_type)
	    @candidates.delete(object_type)
	  end
	end
      end

      # Inject a ValueField for each value type that's a table:
      def inject_value_fields
	@candidates.each do |object_type, candidate|
	  mapping = candidate.mapping
	  if object_type.is_a?(MM::ValueType) and !mapping.all_member.detect{|m| m.is_a?(MM::ValueField)}
	    trace :relational, "Adding value field for #{object_type.name}"
	    @constellation.ValueField(:new, parent: mapping, name: "Value", object_type: object_type)
	    mapping.re_rank
	  end
	end
      end

    end
  end
end
