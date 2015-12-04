#
# ActiveFacts Compositions, Relational Compositor.
#
#	Computes an Optimal Normal Form (close to 5NF) relational schema.
#
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Relational < Compositor
    private
      MM = ActiveFacts::Metamodel
    public
      def generate
	trace :relational_mapping, "Generating relational composition" do
	  super

	  # Make a data structure to help in computing the tables
	  make_candidates

	  # Apply any obvious table/non-table factors
	  assign_default_tabulation

	  # Figure out how best to absorb things to reduce the number of tables
	  optimise_absorption

	  # Remove the un-used absorption paths
	  delete_reverse_absorptions

	  # Actually make a Composite object for each table:
	  make_composites

	  # If a value type has been mapped to a table, add a column to hold its value
	  inject_value_fields

	  # Traverse the absorbed objects to build the path to each required column, including foreign keys:
	  absorb_all_columns

	  # Remove mappings for objects we have absorbed
	  clean_unused_mappings

	  trace :relational_, "Full relational composition" do
	    @composition.all_composite.sort_by{|composite| composite.mapping.name}.each do |composite|
	      composite.mapping.show_trace
	    end
	  end
	end
      end

      def make_candidates
	@candidates = @binary_mappings.inject({}) do |hash, (absorption, mapping)|
	  hash[mapping.object_type] = Candidate.new(mapping)
	  hash
	end
      end

      def assign_default_tabulation
	trace :relational_mapping, "Preparing relational composition by setting default assumptions" do
	  @candidates.each do |object_type, candidate|
	    candidate.assign_default
	  end
	end
      end

      def optimise_absorption
	trace :relational_mapping, "Optimise Relational Composition" do
	  undecided = @candidates.keys.select{|object_type| @candidates[object_type].is_tentative}
	  pass = 0
	  finalised = []
	  begin
	    pass += 1
	    trace :relational_mapping, "Starting optimisation pass #{pass}" do
	      finalised = optimise_absorption_pass(undecided)
	    end
	    trace :relational_mapping, "Finalised #{finalised.size} on this pass: #{finalised.map{|f| f.name}*', '}"
	    undecided -= finalised
	  end while !finalised.empty?
	end
      end

      def optimise_absorption_pass undecided
	possible_flips = {}
	undecided.select do |object_type|
	  candidate = @candidates[object_type]
	  trace :relational_mapping, "Considering possible status of #{object_type.name}" do

	    # Rule 1: Always absorb an objectified unary into its role player:
	    if (f = object_type.fact_type) && f.all_role.size == 1
	      trace :relational_mapping, "Absorb objectified unary #{object_type.name} into #{f.all_role.single.object_type.name}"
	      candidate.definitely_not_table
	      next object_type
	    end

	    # Rule 2: If the preferred_identifier contains one role only, played by an entity type that can absorb us, do that:
	    absorbing_ref = nil
	    pi_roles = []
	    if object_type.is_a?(MM::EntityType) and		  # We're an entity type
	      (pi_roles = object_type.preferred_identifier_roles).size == 1 and	  # Our PI has one role
	      pi_roles[0].object_type.is_a?(MM::EntityType) and	  # played by another Entity Type
	      candidate.references_from.detect do |absorption|
		  next unless absorption.is_a?(MM::Absorption)
		  next unless absorption.child_role == pi_roles[0] # Not the identifying absorption

		  # Look at the other end; make sure it's a forward absorption:
		  absorption = absorption.reverse_absorption ? absorption.reverse_absorption : absorption.flip!

		  next absorbing_ref = absorption
		end
	      trace :relational_mapping, "#{object_type.name} is fully absorbed along its sole reference path #{absorbing_ref.inspect}"
	      candidate.definitely_not_table
	      next object_type
	    end

	    # Rule 3: If there's more than one absorption path and any functional dependencies that can't absorb us, it's a table
	    # REVISIT: If one of the absorption paths is our identifier, we can be absorbed into that with out dependencies, and the other absorption paths can just reference us there...
	    non_identifying_refs_from =
	      candidate.references_from.reject do |absorption|
		absorption.is_a?(MM::Absorption) && pi_roles.include?(absorption.child_role.base_role)
	      end
	    trace :relational_mapping, "#{object_type.name} has #{non_identifying_refs_from.size} non-identifying functional roles" do
	      non_identifying_refs_from.each do |a|
		trace :relational_mapping, a.inspect
	      end
	    end

	    trace :relational_mapping, "#{object_type.name} has #{candidate.references_to.size} references to it" do
	      candidate.references_to.each do |a|
		trace :relational_mapping, a.inspect
	      end
	    end
	    if candidate.references_to.size > 1 and
		non_identifying_refs_from.size > 0
	      trace :relational_mapping, "#{object_type.name} has #{non_identifying_refs_from.size} non-identifying functional dependencies and #{candidate.references_to.size} absorption paths so 3NF requires it be a table"
	      candidate.definitely_table
	      next object_type
	    end

	    # At this point, this object has no functional dependencies that would prevent its absorption
	    next false if !candidate.is_table	# We can't reduce the number of tables by absorbing this one

	    absorption_paths =
	      ( non_identifying_refs_from +   # But we should exclude any that are already involved in an absorption; pre-decided ET=>ET or supertype absorption!
	        candidate.references_to
	      ).reject do |a|
		next true unless a.is_a?(MM::Absorption)
		cc = @candidates[a.child_role.object_type]
		next true if !cc.is_table
		next true if !(a.child_role.is_unique && a.parent_role.is_unique)

		# Allow the sole identifying role for this object
		next false if pi_roles.size == 1 && pi_roles.include?(a.parent_role)
		next true unless a.parent_role.is_mandatory
		next true if cc.is_absorbed # REVISIT: We can be absorbed into something that's also absorbed, but not into us!
		false
	      end

	    trace :relational_mapping, "#{object_type.name} has #{absorption_paths.size} absorption paths"

	    # Rule 4: If this object can be fully absorbed along non-identifying roles, do that (maybe flip some absorptions)
	    if absorption_paths.size > 0
	      trace :relational_mapping, "#{object_type.name} is fully absorbed in #{absorption_paths.size} places" do
		absorption_paths.each do |a|
		  flip = a.reverse_absorption
		  a.flip! if flip
		  trace :relational_mapping, "#{object_type.name} is FULLY ABSORBED via #{a.inspect}#{flip ? ' (flipped)' : ''}"
		end
	      end

	      candidate.definitely_not_table
	      candidate.is_absorbed = true
	      next object_type
	    end

	    # Rule 5: If this object has no functional dependencies, it can be fully absorbed (must be along an identifying role?)
	    if non_identifying_refs_from.size == 0
	      trace :relational_mapping, "#{object_type.name} is fully absorbed in #{candidate.references_to.size} places: #{candidate.references_to.map{|ref| ref.inspect}*", "}"
	      candidate.definitely_not_table
	      candidate.is_absorbed = true
	      next object_type
	    end

	    false   # Otherwise we failed to make a decision about this object type
	  end
	end
      end

      # Remove the unused reverse absorptions:
      def delete_reverse_absorptions
	@binary_mappings.each do |object_type, mapping|
	  mapping.all_member.to_a.		# Avoid problems with deletion from all_member
	  each do |member|
	    next unless member.is_a?(MM::Absorption)
	    member.retract if member.reverse_absorption	# This is the reverse of some absorption
	  end
	  mapping.re_rank
	end
      end

      # Inject a ValueField for each value type that's a table:
      def inject_value_fields
	@constellation.Composite.each do |key, composite|
	  mapping = composite.mapping
	  if mapping.object_type.is_a?(MM::ValueType) and !mapping.all_member.detect{|m| m.is_a?(MM::ValueField)}
	    trace :relational_mapping, "Adding value field for #{mapping.object_type.name}"
	    @constellation.ValueField(
	      :new,
	      parent: mapping,
	      name: mapping.object_type.name+" Value",
	      object_type: mapping.object_type
	    )
	    mapping.re_rank
	  end
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
	    @candidates.delete(object_type)
	  end
	end
      end

      def clean_unused_mappings
	@candidates.keys.to_a.each do |object_type|
	  candidate = @candidates[object_type]
	  next if candidate.is_table
	  mapping = candidate.mapping
	  mapping.retract
	  @binary_mappings.delete(object_type)
	end
      end

      # Absorb all items which aren't tables (and keys to those which are) recursively
      def absorb_all_columns
	trace :relational_mapping, "Absorbing full contents of all tables" do
	  @composition.all_composite_by_name.each do |composite|
	    trace :relational_mapping, "Absorbing contents of #{composite.mapping.name}" do
	      absorb_all composite.mapping, nil
	    end
	  end
	end
      end

      def absorb_all mapping, from
	(from||mapping).all_member.each do |member|
	  member = fork_component_to_new_parent mapping, member if from	  # Top-level members are already instantiated
	  if member.is_a?(MM::Absorption)
	    # Should we absorb a foreign key or the whole contents?
	    table = @candidates[member.child_role.object_type]
	    trace :relational_mapping, "Absorbing #{table ? 'key' : 'contents'} of #{member.child_role.name} in #{member.inspect_reading}" do
	      target = @binary_mappings[member.child_role.object_type]
	      if table
		absorb_key member, target
	      else
		absorb_all member, target
	      end
	    end
	  end
	end
	# mapping.re_rank
      end

      # Recursively add members to this component for the existential roles of
      # the composite mapping for the absorbed (child_role) object:
      def absorb_key mapping, target
	target.all_member.each do |member|
	  next unless member.rank_key[0] == MM::Component::RANK_IDENT
	  member = fork_component_to_new_parent mapping, member
	  if member.is_a?(MM::Absorption)
	    absorb_key member, @binary_mappings[member.child_role.object_type]
	  end
	end
	# mapping.re_rank
      end

      def fork_component_to_new_parent parent, component
	case component
	# A place to put more special cases.
	when MM::ValueField
	  # When we fork from a ValueField, we want to use the name of the ValueType, not the ValueField name
	  @constellation.fork component, guid: :new, parent: parent, name: component.object_type.name
	else
	  @constellation.fork component, guid: :new, parent: parent
	end
      end

      # A candidate is a Mapping of an object type which may become a Composition (a table, in relational-speak)
      class Candidate
	attr_reader :mapping, :is_table, :is_tentative
	attr_accessor :is_absorbed

	def initialize mapping
	  @mapping = mapping
	end

	def object_type
	  @mapping.object_type
	end

	# References from us are things we can absorb and have a forward absorption for
	def references_from
	  # Anything that's not a Mapping must be an Absorption
	  @mapping.all_member.select{|m| !m.is_a?(MM::Mapping) or !m.reverse_absorption && m.parent_role.is_unique }
	end
	alias_method :rf, :references_from

	# References to us are things that can absorb us and they have a forward absorption for
	def references_to
	  @mapping.all_member.map{|m| m.is_a?(MM::Mapping) ? m.reverse_absorption : nil}.compact.select{|r| r.parent_role.is_unique }
	end
	alias_method :rt, :references_to

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
	    trace :relational_mapping, "#{o.name} is a table because it's declared independent or separate"
	    definitely_table
	    return
	  end

	  case o
	  when MM::ValueType
	    if o.is_auto_assigned
	      trace :relational_mapping, "#{o.name} is not a table because it is auto assigned"
	      definitely_not_table
	    elsif references_from.size > 0
	      trace :relational_mapping, "#{o.name} is a table because it has references to absorb"
	      definitely_table
	    else
	      trace :relational_mapping, "#{o.name} is not a table because it will be absorbed wherever needed"
	      definitely_not_table
	    end

	  when MM::EntityType
	    if references_to.empty? and
		!references_from.detect do |absorption|	  # detect whether anything can absorb this entity type
		  absorption.is_a?(MM::Mapping) && absorption.parent_role.is_unique && absorption.child_role.is_unique
		end
	      trace :relational_mapping, "#{o.name} is a table because it has nothing to absorb it"
	      definitely_table
	      return
	    end
	    if !o.supertypes.empty?
	      # We know that this entity type is not a separate or partitioned subtype, so a supertype that can absorb us does
	      identifying_fact_type = o.preferred_identifier.role_sequence.all_role_ref.to_a[0].role.fact_type
	      if identifying_fact_type.is_a?(MM::TypeInheritance)
		trace :relational_mapping, "#{o.name} is absorbed into supertype #{identifying_fact_type.supertype_role.name}"
		definitely_not_table
	      else
		trace :relational_mapping, "Subtype #{o.name} is initially presumed to be a table"
		probably_not_table
	      end
	      return
	    end	# subtype

	    v = nil
	    if references_to.size > 1 and   # Can be absorbed in more than one place
		o.preferred_identifier.role_sequence.all_role_ref.detect do |rr|
		  (v = rr.role.object_type).is_a?(MM::ValueType) and v.is_auto_assigned
		end
	      trace :relational_mapping, "#{o.name} must be a table to support its auto-assigned identifier #{v.name}"
	      definitely_table
	      return
	    end

	    trace :relational_mapping, "#{o.name} is initially presumed to be a table"
	    probably_table

	  end	# case
	end

      end

    end
  end
end
