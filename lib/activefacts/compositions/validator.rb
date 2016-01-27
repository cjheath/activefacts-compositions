#
# ActiveFacts Compositions validator.
#
# Quite a few constraints are not enforced during the construction of a composition.
# This method does a post-validation to ensure that everything looks ok.
# 
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions/compositor"

module ActiveFacts
  module Compositions
    class Compositor
      def validate &report
	report ||= proc do |component, problem|
	  raise "Problem with #{component.inspect}: #{problem}"
	end

	@composition.all_composite.each do |composite|
	  validate_composite composite, &report
	end
      end

    private
      MM = ActiveFacts::Metamodel

      def validate_composite composite, &report
	trace :composition_validator?, "Validating #{composite.inspect}" do
	  report.call(composite, "Has no Mapping") unless composite.mapping
	  report.call(composite, "Mapping is not a mapping") unless composite.mapping.class == MM::Mapping
	  report.call(composite.mapping, "Has no ObjectType") unless composite.mapping.object_type
	  report.call(composite.mapping, "Has no Name") unless composite.mapping.name
	  report.call(composite.mapping, "Should not have an Ordinal rank") if composite.mapping.ordinal
	  report.call(composite.mapping, "Should not have a parent mapping") if composite.mapping.parent
	  report.call(composite.mapping, "Should be the root of its mapping") if composite.mapping.root != composite

	  validate_members composite.mapping, &report
	  validate_access_paths composite, &report
	end
      end

      def validate_members mapping, &report
	# Names (except of subtype/supertype absorption) must be unique:
	names = mapping.
	  all_member.
	  reject{|m| m.is_a?(MM::Absorption) && m.parent_role.fact_type.is_a?(MM::TypeInheritance)}.
	  map(&:name).
	  compact
	duplicate_names = names.select{|name| names.count(name) > 1}.uniq
	report.call(mapping, "Contains duplicated names #{duplicate_names.map(&:inspect)*', '}") unless duplicate_names.empty?

	mapping.all_member.each do |member|
	  trace :composition_validator?, "Validating #{member.inspect}" do
	    report.call(member, "Requires a name") unless MM::Absorption === member && member.flattens or member.name && !member.name.empty?
	    case member
	    when MM::Absorption
	      p = member.parent_role
	      c = member.child_role
	      report.call(member, "Roles should belong to the same fact type, but instead we have #{p.name} in #{p.fact_type.default_reading} and #{c.name} in #{c.fact_type.default_reading}") unless p.fact_type == c.fact_type
	      report.call(member, "Object type #{member.object_type.name} should play the child role #{c.name}") unless member.object_type == c.object_type
	      report.call(member, "Parent mapping object type #{mapping.object_type.name} should play the parent role #{p.name}") unless mapping.object_type == p.object_type

	      validate_reverse member, &report
	      validate_nesting member, &report if member.all_nesting.size > 0

	      validate_members member, &report

	    when MM::Scoping
	      report.call(member, "REVISIT: Unexpected and unchecked Scoping")

	    when MM::ValueField
	      # Nothing to check here

	    when MM::SurrogateKey
	      # Nothing to check here

	    when MM::Injection
	      report.call(member, "REVISIT: Unexpected and unchecked Injection")

	    when MM::Mapping
	      report.call(member, "A child Component should not be a bare Mapping")

	    when MM::Indicator
	      report.call(member, "Indicator requires a Role") unless member.role

	    when MM::Discriminator
	      report.call(member, "Discriminator requires at least one Discriminated Role") if member.all_discriminated_role.empty?
	      member.all_discriminated_role.each do |role|
		report.call(member, "Discriminated Role #{role.name} is not played by parent object type #{mapping.object_type.name}") unless role.object_type == mapping.object_type
	      end
	      # REVISIT: Discriminated Roles must have distinct values matching the type of the Role
	    end
	  end
	end
      end

      def validate_reverse absorption, &report
	reverse = absorption.forward_absorption || absorption.reverse_absorption
	return unless reverse
	report.call(absorption, "Opposite absorption's child role #{reverse.child_role.name} should match parent role #{absorption.parent_role.name}") unless reverse.child_role == absorption.parent_role
	report.call(absorption, "Opposite absorption's parent role #{reverse.parent_role.name} should match child role #{absorption.child_role.name}") unless reverse.parent_role == absorption.child_role
      end

      def validate_nesting absorption, &report
	report.call(absorption, "REVISIT: Unexpected and unchecked Nesting")
	report.call(absorption, "Nesting Mode must be specified") unless absorption.nesting_mode
	# REVISIT: Nesting names must be unique
	# REVISIT: Nesting roles must be played by...
	# REVISIT: Nesting roles must be value types
      end

      def validate_access_paths composite, &report
	composite.all_access_path.each do |access_path|
	  report.call(access_path, "Must contain at least one IndexField") unless access_path.all_index_field.size > 0
	  access_path.all_index_field.each do |index_field|
	    report.call(access_path, "#{index_field.inspect} must be an Indicator or played by a ValueType") unless index_field.component.is_a?(MM::Indicator) || index_field.component.object_type.is_a?(MM::ValueType)
	    report.call(access_path, "#{index_field.inspect} must be within its composite") unless index_field.component.root == composite
	  end
	  if MM::ForeignKey === access_path
	    if access_path.all_index_field.size == access_path.all_foreign_key_field.size
	      access_path.all_index_field.to_a.zip(access_path.all_foreign_key_field.to_a).each do |index_field, foreign_key_field|
		report.call(access_path, "#{index_field.inspect} must have matching target type") unless index_field.component.class == foreign_key_field.component.class
		unless index_field.component.class == foreign_key_field.component.class
		  report.call(access_path, "#{index_field.inspect} must have component type matching #{foreign_key_field.inspect}")
		else
		  report.call(access_path, "#{index_field.inspect} must have matching target type") unless !index_field.component.is_a?(MM::Absorption) or index_field.component.object_type == foreign_key_field.component.object_type
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
  end
end
