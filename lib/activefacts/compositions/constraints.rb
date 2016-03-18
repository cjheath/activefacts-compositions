#
# ActiveFacts Compositions, Metamodel aspect for Constraint classification
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

    class Component
      def gather_constraints all_composite_roles = [], all_composite_constraints = [], constraints_by_leaf = {}
        all_role.each do |role|
          all_composite_roles << role
          role.all_constraint.each do |constraint|
            # Exclude single-role mandatory constraints and all uniqueness constraints:
            next if constraint.is_a?(PresenceConstraint) and
              constraint.max_frequency == 1 ||
              (constraint.role_sequence.all_role_ref.size == 1 && constraint.min_frequency == 1 && constraint.is_mandatory)
            all_composite_constraints << constraint
            (constraints_by_leaf[self] ||= []) << constraint
          end
        end

        gather_nested_constraints all_composite_roles, all_composite_constraints, constraints_by_leaf
      end

      def gather_nested_constraints all_composite_roles, all_composite_constraints, constraints_by_leaf 
        all_member.each do |member|
          member.gather_constraints all_composite_roles, all_composite_constraints, constraints_by_leaf
        end
      end
    end

    class Absorption
      def gather_nested_constraints all_composite_roles, all_composite_constraints, constraints_by_leaf 
        return if foreign_key # This has gone far enough!
        super
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
        # We recurse down the hierarchy, stopping at any foreign keys
        all_composite_roles = []
        all_composite_constraints = []
        constraints_by_leaf = {}
        mapping.gather_constraints all_composite_roles, all_composite_constraints, constraints_by_leaf
        all_composite_roles.uniq!
        all_composite_constraints.uniq!

        # Spanning constraints constrain some role outside this composite:
        spanning_constraints =
          all_composite_constraints.select do |constraint|
            (constraint.all_constrained_role-all_composite_roles).size > 0
          end
        spanning_constraints.each do |spanning_constraint|
          constellation.SpanningConstraint(composite: self, spanning_constraint: spanning_constraint)
        end

        # Local and leaf constraints are what remains. Extract the leaf constraints:
        local_constraints = all_composite_constraints - spanning_constraints
        leaves.each do |leaf|
          # Find any constraints that affect just this leaf:
          leaf_constraints =
            leaf.path.flat_map{|component| Array(constraints_by_leaf[component]) }.
            select do |constraint|
              # Does this constraint constrain only this leaf?
              (constraint.all_constrained_role - leaf.path.flat_map(&:all_role)).size == 0
            end
          leaf_constraints.each do |leaf_constraint|
            constellation.LeafConstraint(component: leaf, leaf_constraint: leaf_constraint)
          end
          local_constraints -= leaf_constraints
        end

        local_constraints.each do |local_constraint|
          constellation.LocalConstraint(composite: self, local_constraint: local_constraint)
        end

      end
    end

  end
end
