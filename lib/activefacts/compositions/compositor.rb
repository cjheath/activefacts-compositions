require "activefacts/metamodel"

module ActiveFacts
  module Compositions
    class Compositor
      def initialize constellation, name, options = {}
	@constellation = constellation
	@name = name
	@options = options
      end

      # Generate all Mappings into @mapping for a binary composition of all ObjectTypes in this constellation
      def generate
	# Retract an existing composition by this name
	if existing = @constellation.Name[[@name]] and
	    @composition = existing.composition
	  @composition.all_composite.to_a.each{|composite| composite.retract}
	  @composition.retract
	end

	@composition = @constellation.Composition(:new, :name => @name)
	populate_references
	# show_references
      end

    private
      def populate_reference object_type, role
	parent = @mappings[role.object_type]

	return if role.fact_type.all_role.size > 2
	if role.fact_type.all_role.size != 1
	  counterpart = role.counterpart
	  rt = role_type(counterpart)
	  if rt == :many_many
	    raise "Can't absorb many-to-many (until we absorb derived fact types, or don't require explicit objectification)"
	  end

	  a = @constellation.Absorption(
	      :new,
	      name: counterpart.name,
	      parent: parent,
	      object_type: counterpart.object_type,
	      parent_role: role,
	      child_role: counterpart
	    )
	  # Populate the absorption/reverse_absorption (putting the "many" or optional side as reverse)
	  if r = @component_by_fact[role.fact_type]
	    # Second occurrence of this fact type, set the direction:
	    if a.is_preferred_direction
	      a.absorption = r
	    else  # Set this as the reverse absorption
	      a.reverse_absorption = r
	    end
	  else
	    # First occurrence of this fact type
	    @component_by_fact[role.fact_type] = a
	  end
	else	# It's an indicator
	  a = @constellation.Indicator(
	      :new,
	      name: role.name,
	      parent: parent,
	      role: role
	    )
	  @component_by_fact[role.fact_type] = a  # For completeness, in case a subclass uses it
	end
	trace :binarize, "Populating #{a.inspect}"
      end

      def populate_references
	# A table of Mappings by object type, with a default Mapping for each:
	@mappings = Hash.new do |h, object_type|
	  h[object_type] = @constellation.Mapping(
	      :new,
	      name: object_type.name,
	      object_type: object_type
	    )
	end
	@component_by_fact = {}

	@constellation.ObjectType.each do |key, object_type|
	  trace :binarize, "Populating possible absorptions for #{object_type.name}" do
	    @mappings[object_type]  # Ensure we create the top Mapping

	    object_type.all_role.each do |role|
	      next if role.mirror_role_as_base_role # Exclude base roles, just use link fact types
	      next if role.variable_as_projection   # REVISIT: Continue to ignore roles in derived fact types?
	      populate_reference object_type, role
	    end
	    if object_type.is_a?(ActiveFacts::Metamodel::ValueType)
	      # This requires a change in the metamodel to use TypeInheritance for ValueTypes
	      if object_type.supertype
		trace :binarize, "REVISIT: Eliding supertype #{object_type.supertype.name} for #{object_type.name}"
	      end
	      object_type.all_value_type_as_supertype.each do |subtype|
		trace :binarize, "REVISIT: Eliding subtype #{subtype.name} for #{object_type.name}"
	      end
	    end
	  end
	end
      end

      def role_type role
	fact_type = role.fact_type
	if fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance)
	  return role.object_type == fact_type.supertype ? :supertype : :subtype
	end

	return :unary if fact_type.all_role.size == 1

	if fact_type.is_a?(ActiveFacts::Metamodel::LinkFactType)
	  # Prevent an unnecessary from-1 search:
	  from_1 = true
	  # Change the to_1 search to detect a one-to-one:
	  role = fact_type.implying_role
	  fact_type = role.fact_type
	end

	# List the UCs on this fact type:
        all_uniqueness_constraints =
          fact_type.all_role.map do |fact_role|
            fact_role.all_role_ref.map do |rr|
              rr.role_sequence.all_presence_constraint.select do |pc|
                pc.max_frequency == 1
              end
            end
          end.flatten.uniq

	# It's to-1 if a UC exists over exactly this role:
        to_1 =
          all_uniqueness_constraints.
            detect do |c|
                (rr = c.role_sequence.all_role_ref.single) and
                rr.role == role
            end 

        if from_1 || fact_type.entity_type
          # This is a role in an objectified fact type
          from_1 = true
        else
          # It's from-1 if a UC exists over roles of this FT that doesn't cover this role:
          from_1 = all_uniqueness_constraints.detect{|uc|
            !uc.role_sequence.all_role_ref.detect{|rr| rr.role == role || rr.role.fact_type != fact_type}
          }
        end

        if from_1
          return to_1 ? :one_one : :one_many
        else
          return to_1 ? :many_one : :many_many
        end
      end

      # Display the primitive binary mapping:
      def show_references
	trace :composition, "Displaying the mappings:" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    trace :composition, "#{object_type.name}" do
	      mapping.all_member.each do |component|
		trace :composition, component.inspect
	      end
	    end
	  end
	end
      end

      # Recursively add members to this component for the existential roles of
      # the composite mapping for the absorbed (child_role) object:
      def absorb_key component
	trace :absorb, "Absorb key of #{component.child_role.object_type.name.inspect} under #{component.inspect}"
=begin
	debugger
	if ActiveFacts::Metamodel::Absorption == component and
	    composite = @mappings[component.child_role.object_type].composite
	  debugger
	  identifying_components = composite.mapping.all_member.select{|m| m.rank_key[0] <= 2}
	  true
	# else nothing more to do here
	end
=end
      end

    end
  end
end
