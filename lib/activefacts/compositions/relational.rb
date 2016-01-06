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

	  trace :relational!, "Full relational composition" do
	    @composition.all_composite.sort_by{|composite| composite.mapping.name}.each do |composite|
	      composite.show_trace
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
	    candidate.assign_default(@composition)
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

	    # Rule 1: Always absorb an objectified unary into its role player (unless its forced to be separate)
	    if !object_type.is_separate && (f = object_type.fact_type) && f.all_role.size == 1
	      absorbing_ref = candidate.mapping.all_member.detect{|a| a.is_a?(MM::Absorption) and a.child_role.base_role == f.all_role.single}
	      if absorbing_ref.parent_role.object_type == object_type
		absorbing_ref = absorbing_ref.flip!
	      end
	      @constellation.FullAbsorption(composition: @composition, absorption: absorbing_ref, object_type: object_type)
	      trace :relational_mapping, "Absorb objectified unary #{object_type.name} into #{f.all_role.single.object_type.name}"
	      candidate.definitely_not_table
	      next object_type
	    end

	    # Rule 2: If the preferred_identifier contains one role only, played by an entity type that can absorb us, do that:
	    # (Leave pi_roles intact for further use below)
	    absorbing_ref = nil
	    pi_roles = []
	    if object_type.is_a?(MM::EntityType) and		  # We're an entity type
	      pi_roles = object_type.preferred_identifier_roles and	# Our PI
	      pi_roles.size == 1 and					# has one role
	      single_pi_role = pi_roles[0] and				# that role is
	      single_pi_role.object_type.is_a?(MM::EntityType) and	# played by another Entity Type
	      absorbing_ref =
		candidate.mapping.all_member.detect do |absorption|
		  next unless absorption.is_a?(MM::Absorption)
		  next unless absorption.parent_role.base_role.fact_type == single_pi_role.fact_type

		  absorption = absorption.flip! if absorption.forward_absorption  # Flip it if it's a reverse_absorption
		  next absorption
		end
	      @constellation.FullAbsorption(composition: @composition, absorption: absorbing_ref, object_type: object_type)
	      trace :relational_mapping, "EntityType #{single_pi_role.object_type.name} identifies EntityType #{object_type.name}, so absorbs it"
	      candidate.definitely_not_table
	      next object_type
	    end

	    # Rule 3: If there's more than one absorption path and any functional dependencies that can't absorb us, it's a table
	    non_identifying_refs_from =
	      candidate.references_from.reject do |member|
		case member
		when MM::Absorption
		  pi_roles.include?(member.child_role.base_role)
		when MM::Indicator
		  pi_roles.include?(member.role)
		else
		  false
		end
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
	    if candidate.references_to.size > 1 and	  # More than one place wants us
		non_identifying_refs_from.size > 0	  # And we carry dependent values so cannot be absorbed
	      trace :relational_mapping, "#{object_type.name} has #{non_identifying_refs_from.size} non-identifying functional dependencies and #{candidate.references_to.size} absorption paths so 3NF requires it be a table"
	      candidate.definitely_table
	      next object_type
	    end

	    # At this point, this object either has no functional dependencies or only one place it would be absorbed
	    next false if !candidate.is_table	# We can't reduce the number of tables by absorbing this one

	    absorption_paths =
	      ( non_identifying_refs_from +   # But we should exclude any that are already involved in an absorption; pre-decided ET=>ET or supertype absorption!
	        candidate.references_to	      # These are our reverse absorptions that could absorb us
	      ).select do |a|
		next false unless a.is_a?(MM::Absorption)   # Skip Indicators, we can't be absorbed there
		next false if a.full_absorption		    # Skip this, we absorb them, it can't be mutual
		next false if a.forward_absorption && a.forward_absorption.full_absorption  # This has happened
		next false if a.reverse_absorption && a.reverse_absorption.full_absorption  # Not sure that this can/will happen
		cc = @candidates[a.child_role.object_type]
		next false unless cc.is_table		    # Other end must already be a table
                # REVISIT: Or if the other end is absorbed into another table???
		next false unless a.child_role.is_unique && a.parent_role.is_unique   # Must be one-to-one

		# next true if pi_roles.size == 1 && pi_roles.include?(a.parent_role) # Allow the sole identifying role for this object
		next false unless a.parent_role.is_mandatory # Don't absorb an object along a non-mandatory role
		# next false if cc.is_absorbed # REVISIT: We can be absorbed into something that's also absorbed, but not into us!
		true
	      end

	    trace :relational_mapping, "#{object_type.name} has #{absorption_paths.size} absorption paths"

	    # Rule 4: If this object can be fully absorbed along non-identifying roles, do that (maybe flip some absorptions)
	    if absorption_paths.size > 0
	      trace :relational_mapping, "#{object_type.name} is fully absorbed in #{absorption_paths.size} places" do
		absorption_paths.each do |a|
		  a = a.flip! if a.forward_absorption
		  # Don't create the full
		  # @constellation.FullAbsorption(composition: @composition, absorption: a, object_type: object_type)
		  trace :relational_mapping, "#{object_type.name} is fully absorbed via #{a.inspect}"
		end
	      end

	      candidate.definitely_not_table
	      candidate.is_absorbed = true
	      next object_type
	    end

	    # Rule 5: If this object has no functional dependencies (only its identifier), it can be absorbed in multiple places
	    # We don't create FullAbsorptions, because they're only used to resolve references to this object; and there are none here
	    if non_identifying_refs_from.size == 0
	      refs_to = candidate.references_to.to_a
	      refs_to.map! do |a|
		a = a.flip! if a.reverse_absorption   # We were forward, but the other end must be
		a = a.forward_absorption
	      	# @constellation.FullAbsorption(composition: @composition, absorption: a, object_type: a.object_type)
		# a
	      end
	      trace :relational_mapping, "#{object_type.name} is fully absorbed in #{refs_to.size} places: #{refs_to.map{|ref| ref.inspect}*", "}"
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
	    member.retract if member.forward_absorption	# This is the reverse of some absorption
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
	    @candidates.delete(object_type)
	  end
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

      # Build a hash of local PresenceConstraints to index the Index we might make for each
      def empty_pc_map_for mapping
	mapping.
	  object_type.
	  all_role.
	  map do |role|
	    c = role.counterpart and
	    c = c.base_role and	    # In case it's a link fact type
	    c.all_role_ref.map do |rr|
	      if rr.
		  role_sequence.
		  all_role_ref.
		  detect do |rr|
		    if rr.role.fact_type.entity_type
		      # Internal uniqueness constraint on an objectified fact type
		      p = rr.role.mirror_role_as_base_role.counterpart
		    else
		      p = rr.role.counterpart
		    end
		    p.object_type != mapping.object_type
		  end
		[]  # All constrained roles must be counterpart roles of this object
	      else
		rr.role_sequence.all_presence_constraint.select{|p| p.max_frequency == 1}
	      end
	    end
	  end.
	  flatten.
	  compact.
	  uniq.
	  inject({}) {|h, pc| h[pc] = nil; h }

	# puts "#{pcs.keys.map(&:describe)}"
      end

      # For the given mapping and a new member, return applicable access_paths,
      # populating the PresenceConstraint->AccessPath map in the process
      def relevant_access_paths mapping, member, base_access_paths, pcs
	case member
	when MM::Indicator
	  role = member.role
	when MM::Absorption
	  return base_access_paths unless member.parent_role.is_unique
	  role = member.child_role
	when MM::ValueField
	  raise "There can be no other Index for a ValueField" unless base_access_paths.empty?
	  ap = [@constellation.Index(:new, composite: mapping.root, is_unique: true, name: member.name+'PK')]
	  ap[0].composite_as_primary_index = mapping.composite if mapping.composite
	  return ap
	end
	return base_access_paths unless role

	# If we aren't at the top level, we can't apply a unique index to this object unless it is one-to-one with the top level
	unique_absorption = true
	root = mapping
	while root.parent
	  unless root.child_role.is_unique
	    unique_absorption = false
	    break
	  end
	  root = root.parent
	end

	if unique_absorption
	  # First find relevant PresenceConstraints for which we need a new Index:
	  new_pcs = pcs.select{ |pc, path| !path && pc.covers_role(role.base_role) }.keys
	  new_pcs.each do |pc|
	    pcs[pc] =
	      access_path = @constellation.Index(:new, composite: mapping.root, is_unique: true)
	    access_path.composite_as_primary_index = mapping.composite if mapping.composite && pc.is_preferred_identifier && root == mapping
	    trace :relational_mapping, "creating new #{access_path.inspect} for #{member.inspect}, PC #{pc.describe}"
	  end
	end

	# Now, for each PresenceConstraint that applies to this member,
	# add the existing path to the base_access_paths and return that:
	ap = base_access_paths
	pcs.each do |pc, path|
	  next unless path && pc.covers_role(role.base_role)
	  ap = ap.dup if ap.equal?(base_access_paths)
	  ap << path
	end
	ap
      end

      # This member is an Absorption. Process it recursively, absorbing all its members
      # or just a key depending on whether the absorbed object is a Composite or not.
      def absorb_nested mapping, member, access_paths
	table = @candidates[member.child_role.object_type]
	full_absorption = @composition.all_full_absorption.detect{|fa| fa.object_type == member.child_role.object_type}
	# Should we absorb a foreign key or the whole contents?

	trace :relational_mapping, "Absorbing nested #{table ? 'key' : 'contents'} of #{member.child_role.name} in #{member.inspect_reading}" do
	  target = @binary_mappings[member.child_role.object_type]
	  if table
	    # Prepare to build a foreign key:
	    access_paths = access_paths.dup
	    access_paths << @constellation.ForeignKey(:new, source_composite: mapping.root, composite: target.composite)
	    trace :relational_mapping, "creating new #{access_paths[-1].inspect} for #{member.inspect}"
	    absorb_key member, target, access_paths
	  elsif full_absorption && full_absorption != member.full_absorption
	    # The target object type is fully absorbed elsewhere. Absorb its key instead.
	    target = @binary_mappings[full_absorption.absorption.parent_role.object_type]
	    absorb_key member, target, access_paths
	  else
	    absorb_all member, target, access_paths
	  end
	end
      end

      # Augment the mapping with copies of the children of the "from" mapping.
      # At the top level, no "from" is given and the children already exist
      def absorb_all mapping, from, access_paths = []

	top_level = !from
	from ||= mapping

	pcs = empty_pc_map_for(from)

	from.re_rank

	ordered = from.all_member.sort_by(&:ordinal)
	ordered.each do |member|
	  unless top_level    # Top-level members are already instantiated
	    member = fork_component_to_new_parent(mapping, member)
	  end

	  ap = relevant_access_paths mapping, member, access_paths, pcs
	  if member.is_a?(MM::Absorption)
	    absorb_nested mapping, member, ap
	  end

	  augment_paths ap, member
	end

	# mapping.re_rank
      end

      # Recursively add members to this component for the existential roles of
      # the composite mapping for the absorbed (child_role) object:
      def absorb_key mapping, target, access_paths
	target.re_rank
	target.all_member.sort_by(&:ordinal).each do |member|
	  next unless member.rank_key[0] == MM::Component::RANK_IDENT
	  member = fork_component_to_new_parent mapping, member
	  augment_paths access_paths, member
	  if member.is_a?(MM::Absorption)
	    absorb_key member, @binary_mappings[member.child_role.object_type], access_paths
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

      # This mapping represents a new element to be added to each AccessPath in the array
      def augment_paths access_paths, mapping
	return if mapping.is_a?(MM::Mapping) and mapping.object_type.is_a?(MM::EntityType)
	access_paths.each do |ap|
	  trace :relational_mapping, "Adding IndexKey for #{mapping.inspect}" do
	    if ap.is_a?(MM::ForeignKey)
	      # REVISIT: The target object may not have had its identifier elaborated yet, and in any case we don't know it.
	      next  # REVISIT: "mapping" relates to a foreign key. The required ForeignKeyField is the matching primary key
	    end
	    @constellation.IndexField(
	      access_path: ap,
	      ordinal: ap.all_index_field.size,
	      component: mapping
	    )
	  end
	  if ap.is_a?(MM::ForeignKey)
	    trace :relational_mapping, "Adding ForeignKeyField for #{mapping.inspect}" do
	      @constellation.ForeignKeyField(foreign_key: ap, ordinal: ap.all_foreign_key_field.size, component: mapping)
	    end
	  end
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

	# References from us are things we can own (non-Mappings) or have a unique forward absorption for
	def references_from
	  @mapping.all_member.select{|m| !m.is_a?(MM::Absorption) or !m.forward_absorption && m.parent_role.is_unique }
	end
	alias_method :rf, :references_from

	# References to us are reverse absorptions where the forward absorption can absorb us
	def references_to
	  @mapping.all_member.select{|m| m.is_a?(MM::Absorption) and f = m.forward_absorption and f.parent_role.is_unique}
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

	def assign_default composition
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
	      identifying_fact_type = o.all_type_inheritance_as_subtype.detect{|ti| ti.provides_identification}
	      if identifying_fact_type
		fact_type = identifying_fact_type
	      else
		if o.all_type_inheritance_as_subtype.size > 1
		  trace :relational_mapping, "REVISIT: #{o.name} cannot be absorbed into a supertype that doesn't also absorb all our other supertypes (or is absorbed into one of its supertypes that does)"
		end
		fact_type = o.all_type_inheritance_as_subtype.to_a[0]
	      end

	      absorbing_ref = mapping.all_member.detect{|m| m.is_a?(MM::Absorption) && m.child_role.fact_type == fact_type}
	      absorbing_ref = absorbing_ref.flip! if absorbing_ref.reverse_absorption   # We were forward, but the other end must be
	      absorbing_ref = absorbing_ref.forward_absorption
	      o.constellation.FullAbsorption(composition: composition, absorption: absorbing_ref, object_type: o)
	      trace :relational_mapping, "Supertype #{fact_type.supertype_role.name} absorbs subtype #{o.name}"
	      definitely_not_table
	      return
	    end	# subtype

	    v = nil
	    if references_to.size > 1 and   # Can be absorbed in more than one place
		o.preferred_identifier.role_sequence.all_role_ref.detect do |rr|
                  # If the preferred_identifier includes a ValueType that's auto-assigned ON COMMIT (like an SQL sequence), we need a single table to control the sequence.
                  # REVISIT: This enforces it also for auto-assignment ON ASSERT, and where the ValueType is actually just a foreign key to another object (in a composite PI)
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
