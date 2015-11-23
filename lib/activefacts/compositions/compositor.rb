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
      def role_counterpart role
	if role.fact_type.all_role.size == 1
	  role
	else
	  (role.fact_type.all_role.to_a-[role])[0]
	end
      end

      def role_type role
	fact_type = role.fact_type
	if fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance)
	  return role.object_type == fact_type.supertype ? :supertype : :subtype
	end

	if fact_type.is_a?(ActiveFacts::Metamodel::LinkFactType)
	  # Prevent an unnecessary from-1 search:
	  from_1 = true
	  # Change the to_1 search to detect a one-to-one:
	  role = fact_type.implying_role
	  fact_type = role.fact_type
	elsif fact_type.all_role.size == 1
	  return :unary
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

      def populate_reference object_type, role
	parent = @mappings[role.object_type]
	counterpart = role_counterpart(role)
	unless counterpart and
	    role.fact_type == counterpart.fact_type
	  debugger
	  role_counterpart(role)
	end

	if counterpart.fact_type.all_role.size != 1 or
	  counterpart.fact_type.is_a?(ActiveFacts::Metamodel::LinkFactType)
	  rt = role_type(counterpart)
	  if rt == :many_many
	    raise "Can't absorb many-to-many (until we absorb derived fact types, or don't require explicit objectification)"
	  end
	  # return if rt == :many_one
	  # return if rt == :supertype  # REVISIT: But look for partition, separate, etc.

	  a = @constellation.Absorption(
	      :new,
	      parent: parent,
	      object_type: counterpart.object_type,
	      parent_role: role,
	      child_role: counterpart
	    )
	  # Populate the absorption/reverse_absorption (putting the "many" or optional side as reverse)
	  if r = @component_by_fact[role.fact_type]
	    if rt == :many_one or	# A non-first-normal-form absorption
		rt == :supertype or	# Could prevent the supertype from standing alone, but that's ok in partition
		rt == :one_one && role.is_mandatory && !counterpart.is_mandatory or	# Could prevent the non-mandatory type standing alone
		rt == :one_one && role.object_type.name > counterpart.object_type.name	# For stability
	      a.reverse_absorption = r
	    else
	      a.absorption = r
	    end
	  else
	    @component_by_fact[role.fact_type] = a
	  end
	else
	  a = @constellation.Indicator(:new, parent: parent, role: role)
	  @component_by_fact[role.fact_type] = a  # For completeness, in case a subclass uses it
	end
	trace :binarize, "Populating #{a.inspect}"
      end

      def populate_references
	@mappings = Hash.new{|h, k| h[k] = @constellation.Mapping(:new, object_type: k)}
	@component_by_fact = {}

	@constellation.ObjectType.each do |key, object_type|
	  trace :binarize, "Populating references for #{object_type.name}" do
	    object_type.all_role.each do |role|
	      next if role.variable_as_projection   # REVISIT: Ignore roles in derived fact types?
	      populate_reference object_type, role
	    end
	  end
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

      def absorb_key component
	# REVISIT: Absorb copies of the existential roles of this component's composition
      end

    end
  end
end
