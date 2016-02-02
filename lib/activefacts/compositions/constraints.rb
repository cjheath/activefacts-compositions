#
# ActiveFacts Compositions, Constraints handling for compositions
# 
# Copyright (c) 2016 Clifford Heath. Read the LICENSE file.
#
require "activefacts/metamodel"

module ActiveFacts
  module Metamodel
    class Composition
      def retract_constraint_classifications
	all_composite.each(&:retract_constraint_classifications)
      end

      def classify_constraints
	retract_constraint_classifications
	all_composite.each(&:classify_constraints)
      end
    end

    class Composite
      def retract_constraint_classifications
	all_spanning_constraint.to_a.each(&:retract)
	all_local_constraint.to_a.each(&:retract)
	mapping.leaves.each do |component|
	  component.all_leaf_constraint.to_a.each(&:retract)
	end
      end

      def classify_constraints
	leaves = mapping.leaves

	# Categorise and index all constraints not already baked-in to the composition
	all_composite_roles = []
	all_composite_constraints = []
	constraints_by_leaf = {}
	leaves.each do |leaf|
	  all_composite_roles += leaf.path.flat_map(&:all_role)	  # May be non-unique, fix later
	  leaf.all_role.each do |role|
	    role.all_constraint.each do |constraint|
	      if constraint.is_a?(PresenceConstraint)
		# Exclude single-role mandatory constraints and all uniqueness constraints:
		if constraint.role_sequence.all_role_ref.size == 1 && constraint.min_frequency == 1 && constraint.is_mandatory or
		    constraint.max_frequency == 1
		  next
		end
	      end
	      all_composite_constraints << constraint
	      (constraints_by_leaf[leaf] ||= []) << constraint
	    end
	  end
	end

	all_composite_roles.uniq!
	all_composite_constraints.uniq!
	spanning_constraints =
	  all_composite_constraints.reject do |constraint|
	    (constraint.all_constrained_role-all_composite_roles).size == 0
	  end
	local_constraints = all_composite_constraints - spanning_constraints

	spanning_constraints.each do |spanning_constraint|
	  constellation.SpanningConstraint(composite: self, spanning_constraint: spanning_constraint)
	end

	leaves.each do |leaf|
	  # Find any constraints that affect just this leaf:
	  leaf_constraints = (constraints_by_leaf[leaf]||[]).
	    reject do |constraint|
	      (constraint.all_constrained_role - leaf.all_role).size > 0
	    end
	  local_constraints -= leaf_constraints
	  leaf_constraints.each do |leaf_constraint|
	    constellation.LeafConstraint(component: leaf, leaf_constraint: leaf_constraint)
	  end
	end

	local_constraints.each do |local_constraint|
	  constellation.LocalConstraint(composite: self, local_constraint: local_constraint)
	end

      end
    end

  end
end
