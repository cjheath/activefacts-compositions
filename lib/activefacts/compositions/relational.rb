require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Relational < Binary
    private
      MM = ActiveFacts::Metamodel

      # A candidate is a Mapping of an object type which may become a Composition (a table, in relational-speak)
      class Candidate
	attr_reader :mapping, :is_table, :tentative

	def initialize mapping
	  @mapping = mapping
	end

	def object_type
	  @mapping.object_type
	end

	def references_from
	  @mapping.all_member.select{|c| c.is_a?(MM::Absorption) && !c.reverse_absorption }
	end
	alias_method :rf, :references_from

	def references_to
	  @mapping.all_member.select{|c| c.is_a?(MM::Absorption) && !c.absorption }
	end
	alias_method :rt, :references_to

	def has_references
	  @mapping.all_member.select{|c| c.is_a?(MM::Absorption) }
	end

	def definitely_not_table
	  @tentative = @is_table = false
	end

	def definitely_table
	  @tentative = false
	  @is_table = true
	end

	def probably_not_table
	  @tentative = true
	  @is_table = false
	end

	def probably_table
	  @tentative = @is_table = true
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
	    elsif references_from.size == 0
	      trace :relational, "#{o.name} is not a table because it has no references to absorb"
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
		preferred_identifier.role_sequence.all_role_ref.detect{|rr|
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

	# decide_tables

	# delete_reverse_absorptions

	# absorb

	trace :relational, "Full relational composition" do
	  @candidates.keys.sort_by(&:name).each do |object_type|
	    candidate = @candidates[object_type]
	    next unless candidate.is_table
	    candidate.mapping.show_trace 
	  end
	end
      end

      def decide_tables
	trace :relational, "deciding Relational Composition" do
	end
      end

=begin
	# These two hashes (on the mapping) say whether that mapping will be a composite (table)
	@is_table = {}
	# And whether that has been definitely decided
	@tentative = {}
	@mappings.each do |object_type, mapping|
	  if object_type.is_separate
	    @is_table[object_type] = true
	    @tentative[object_type] = false
	    next
	  end

	  # RANK_SUPER, RANK_IDENT, RANK_VALUE, RANK_INJECTION, RANK_DISCRIMINATOR, RANK_FOREIGN, RANK_INDICATOR, RANK_MANDATORY, RANK_NON_MANDATORY, RANK_MULTIPLE, RANK_SUBTYPE, RANK_SCOPING

	  three_nf = [ RANK_IDENT, RANK_MANDATORY, RANK_NON_MANDATORY, RANK_INDICATOR, RANK_DISCRIMINATOR]
	  references_from = mapping.all_member.select{|m| three_nf.include?(m.rank_key[0])}
	  if object_type.is_a?(MM::ValueType)
	    @is_table[object_type] = !references_from.empty? && !object_type.is_auto_assigned
	    @tentative[object_type] = false
	  else
	    references_to = mapping.all_member.select{|m| m.rank_key[0] == RANK_MULTIPLE}
	    @tentative[object_type] = false     # Assume we'll make binding decisions

	    # Always a table if it has nowhere else to go, and has no one-to-ones that might flip:
	    if references_to.empty? and !references_from.detect{|r| r.is_one_to_one}
	      @is_table[object_type] = true
	      next
	    end

	    # A subtype may be partitioned or separate, in which case it's definitely a table.
	    # Otherwise, if its identification is inherited from a supertype, they're definitely absorbed.
	    # If it has separate identification, that might absorb this.
	    if !object_type.supertypes.empty?
	      as_ti = object_type.all_supertype_inheritance.detect{|ti| ti.assimilation && ti.assimilation != 'absorbed'}
	      partitioned_or_separate = as_ti != nil
	      if partitioned_or_separate
		@is_table[object_type] = true
		trace :absorption, "EntityType #{name} is #{as_ti.assimilation} from supertype #{as_ti.supertype}"
	      else
		identifying_fact_type = object_type.preferred_identifier.role_sequence.all_role_ref.to_a[0].role.fact_type
		if identifying_fact_type.is_a?(TypeInheritance)
		  trace :absorption, "EntityType #{name} is absorbed into supertype #{supertypes[0].name}"
		  @is_table[object_type] = false
		else
		  # This subtype is not identified by a supertype (it has independent identification)
		  # Possibly absorbed, we'll have to see how that pans out. Try for independent first.
		  @tentative[object_type] = true
		end
	      end
	      next
	    end

	    # If the preferred_identifier includes an auto_assigned ValueType
	    # and this object is absorbed in more than one place, we need a table
	    # to manage the auto-assignment.
	    if references_to.size > 1 and
	      object_type.preferred_identifier.role_sequence.all_role_ref.detect do |rr|
		next false unless rr.role.object_type.is_a? ValueType
		rr.role.object_type.is_auto_assigned
	      end
	      trace :absorption, "#{object_type.name} has an auto-assigned counter in its ID, so must be a table"
	      @is_table[object_type] = true
	      next
	    end

	    @tentative[object_type] = true	  # No default rule to apply, so we're unsure
	    @is_table[object_type] = true	  # Guess it will be a table
	  end
	end
=end

      # Remove any multi-valued absorptions:
      def drop_multiples
	@mappings.each do |object_type, mapping|
	  mapping.all_member.to_a.		# Avoid problems with deletion from all_member
	  each do |member|
	    member.retract if member.rank_key[0] == MM::Component::RANK_MULTIPLE
	  end
	end
      end

      # Absorb all items which aren't tables (and keys to those which are) recursively
      def absorb
      end

      # Inject a ValueField for each value type that's a table:
      def inject_value_fields
	@mappings.each do |object_type, mapping|
	  if object_type.is_a?(MM::ValueType) and !mapping.all_member.detect{|m| m.is_a?(MM::ValueField)}
	    @constellation.ValueField(:new, parent: mapping, name: "Value", object_type: object_type)
	  end
	end
      end

      # After all table/non-table decisions are made, convert table mappings into Composites and drop the rest:
      def make_composites
	@mappings.keys.to_a.	# Avoid problems with deletions
	each do |object_type|
	  mapping = @mapping[object_type]
	  if @is_table[object_type]
	    composite = @constellation.Composite(mapping, composition: @composition)
	  else
	    @mappings.delete(object_type)
	  end
	end
      end

    end
  end
end
