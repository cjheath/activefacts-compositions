#
# ActiveFacts Compositions, Metamodel aspect to look for validation errors in a composition
#
# Quite a few constraints are not enforced during the construction of a composition.
# This method does a post-validation to ensure that everything looks ok.
# 
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/metamodel"
require "activefacts/compositions/compositor"
require "activefacts/generators"

module ActiveFacts
  module Generators
    class Validate
      def initialize composition, options = {}
	@composition = composition
	@options = options
      end

      def generate &b
	@composition.validate &b
	nil
      end
    end
    publish_generator Validate
  end

  module Metamodel
    class Composition
      def validate &report
        trace.enable 'composition_validator'
	report ||= proc do |component, problem|
	  trace :composition_validator, "!!PROBLEM!! #{component.inspect}: #{problem}"
	end

	all_composite.each do |composite|
	  composite.validate &report
	end
      end
    end

    class Composite
      def validate &report
	trace :composition_validator?, "Validating #{inspect}" do
	  report.call(self, "Has no Mapping") unless mapping
	  report.call(self, "Mapping is not a mapping") unless mapping.class == Mapping
	  report.call(mapping, "Has no ObjectType") unless mapping.object_type
	  report.call(mapping, "Has no Name") unless mapping.name
	  report.call(mapping, "Should not have an Ordinal rank") if mapping.ordinal
	  report.call(mapping, "Should not have a parent mapping") if mapping.parent
	  report.call(mapping, "Should be the root of its mapping") if mapping.root != self

	  mapping.validate_members &report
	  validate_access_paths &report
	end
      end

      def validate_access_paths &report
	all_access_path.each do |access_path|
	  report.call(access_path, "Must contain at least one IndexField") unless access_path.all_index_field.size > 0
	  access_path.all_index_field.each do |index_field|
	    report.call(access_path, "#{index_field.inspect} must be an Indicator or played by a ValueType") unless index_field.component.is_a?(Indicator) || index_field.component.object_type.is_a?(ValueType)
	    report.call(access_path, "#{index_field.inspect} must be within its composite") unless index_field.component.root == self
	  end
	  if ForeignKey === access_path
	    if access_path.all_index_field.size == access_path.all_foreign_key_field.size
	      access_path.all_index_field.to_a.zip(access_path.all_foreign_key_field.to_a).each do |index_field, foreign_key_field|
		report.call(access_path, "#{index_field.inspect} must have matching target type") unless index_field.component.class == foreign_key_field.component.class
		unless index_field.component.class == foreign_key_field.component.class
		  report.call(access_path, "#{index_field.inspect} must have component type matching #{foreign_key_field.inspect}")
		else
		  report.call(access_path, "#{index_field.inspect} must have matching target type") unless !index_field.component.is_a?(Absorption) or index_field.component.object_type == foreign_key_field.component.object_type
		end
		report.call(access_path, "#{foreign_key_field.inspect} must be within the target composite") unless foreign_key_field.component.root == access_path.source_composite
	      end
	    else
	      report.call(access_path, "has #{access_path.all_index_field.size} index fields but #{access_path.all_foreign_key_field.size} ForeignKeyField")
	    end
	  end
	end
      end
    end

    class Mapping
      def validate_members &report
	# Names (except of subtype/supertype absorption) must be unique:
	names = all_member.
	  reject{|m| m.is_a?(Absorption) && m.parent_role.fact_type.is_a?(TypeInheritance)}.
	  map(&:name).
	  compact
	duplicate_names = names.select{|name| names.count(name) > 1}.uniq
	report.call(self, "Contains duplicated names #{duplicate_names.map(&:inspect)*', '}") unless duplicate_names.empty?

	all_member.each do |member|
	  trace :composition_validator?, "Validating #{member.inspect}" do
	    report.call(member, "Requires a name") unless Absorption === member && member.flattens or member.name && !member.name.empty?
	    case member
	    when Absorption
	      p = member.parent_role
	      c = member.child_role
	      report.call(member, "Roles should belong to the same fact type, but instead we have #{p.name} in #{p.fact_type.default_reading} and #{c.name} in #{c.fact_type.default_reading}") unless p.fact_type == c.fact_type
	      report.call(member, "Object type #{member.object_type.name} should play the child role #{c.name}") unless member.object_type == c.object_type
	      report.call(member, "Parent mapping object type #{object_type.name} should play the parent role #{p.name}") unless object_type == p.object_type

	      member.validate_reverse &report
	      member.validate_nesting &report if member.all_nesting.size > 0
	      member.validate_members &report

	    when Scoping
	      report.call(member, "REVISIT: Unexpected and unchecked Scoping")

	    when ValueField
	      # Nothing to check here

	    when SurrogateKey
	      # Nothing to check here

	    when Injection
	      report.call(member, "REVISIT: Unexpected and unchecked Injection")

	    when Mapping
	      report.call(member, "A child Component should not be a bare Mapping")

	    when Indicator
	      report.call(member, "Indicator requires a Role") unless member.role

	    when Discriminator
	      report.call(member, "Discriminator requires at least one Discriminated Role") if member.all_discriminated_role.empty?
	      member.all_discriminated_role.each do |role|
		report.call(member, "Discriminated Role #{role.name} is not played by parent object type #{object_type.name}") unless role.object_type == object_type
	      end
	      # REVISIT: Discriminated Roles must have distinct values matching the type of the Role
	    end
	  end
	end
      end
    end

    class Absorption
      def validate_reverse &report
	reverse = forward_absorption || reverse_absorption
	return unless reverse
	report.call(self, "Opposite absorption's child role #{reverse.child_role.name} should match parent role #{parent_role.name}") unless reverse.child_role == parent_role
	report.call(self, "Opposite absorption's parent role #{reverse.parent_role.name} should match child role #{child_role.name}") unless reverse.parent_role == child_role
      end

      def validate_nesting &report
	report.call(self, "REVISIT: Unexpected and unchecked Nesting")
	report.call(self, "Nesting Mode must be specified") unless self.nesting_mode
	# REVISIT: Nesting names must be unique
	# REVISIT: Nesting roles must be played by...
	# REVISIT: Nesting roles must be value types
      end
    end

  end
end
