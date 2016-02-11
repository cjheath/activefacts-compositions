#
#       ActiveFacts Object-Oriented API Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    class ObjectOriented
      def initialize composition, options = {}
	@composition = composition
	@options = options
	@comments = @options.delete("comments")
      end

      def generate
	@composites_emitted = {}

	retract_intrinsic_types

	prelude(@composition) +
	@composition.
        all_composite.
        sort_by{|composite| composite.mapping.name}.
	map do |composite|
	  generate_class(composite)
	end.
	compact.
	join("\n") +
	finale
      end

      def composite_for object_type
	@composition.all_composite.detect{|c| c.mapping.object_type == object_type }
      end

      # We don't need Composites for object types that are built-in to the Ruby API.
      def is_intrinsic_type composite
	o = composite.mapping.object_type
	o.name == "_ImplicitBooleanValueType" || !o.supertype
      end

      def retract_intrinsic_types
	@composition.
        all_composite.
        sort_by{|composite| composite.mapping.name}.
	each do |composite|
	  o = composite.mapping.object_type
	  next unless o.is_a?(MM::ValueType)
	  composite.retract and next if is_intrinsic_type(composite)
	end
      end

      def inherited_identification
	''
      end

      def identified_by_roles identifying_roles
	"REVISIT: override identified_by_roles\n"
      end

      def value_type_declaration object_type
	"REVISIT: override value_type_declaration\n"
      end

      def class_prelude(object_type, supertype)
	"REVISIT: override class_prelude\n"
      end

      def class_finale(object_type)
	"REVISIT: override class_finale\n"
      end

      def generate_class composite
	return nil if @composites_emitted[composite]
	@composites_emitted[composite] = true

	mapping = composite.mapping
	object_type = mapping.object_type
	is_entity_type = object_type.is_a?(MM::EntityType)
	supertype = is_entity_type ? object_type.identifying_supertype : object_type.supertype

	# Emit supertypes before subtypes
	if supertype and
	    supertype_composite = composite_for(supertype)
	  supertype_definition = generate_class(supertype_composite)
	  supertype_definition += "\n" if supertype_definition
	end

	# Select the members that will be declared as O-O roles:
	mapping.re_rank
	members = mapping.
	  all_member.
	  sort_by{|m| m.ordinal}.
	  reject do |m|
	    m.is_a?(MM::Absorption) and
	      m.forward_absorption || m.child_role.fact_type.is_a?(MM::TypeInheritance)
	  end

	# For those roles that derive from Mappings, produce class definitions to avoid forward references:
	forward_declarations =
	  members.
	  select{ |m| m.is_a?(MM::Mapping) }.
	  map{ |m| composite_for m.object_type }.
	  compact.
	  sort_by{|c| c.mapping.name}.
	  map{|c| generate_class(c)}.
	  compact * "\n"
	forward_declarations += "\n" unless forward_declarations.empty?

	type_declaration =
	  if is_entity_type
	    if supertype and object_type.identification_is_inherited
	      inherited_identification
	    else
	      identifying_roles =
		if object_type.fact_type && object_type.fact_type.is_unary
		  # Objectified unary; find the absorption over the LinkFactType
		  members.
		    select{|m| m.is_a?(MM::Absorption) && m.child_role.base_role.fact_type.entity_type}.
		    map{|m| m.child_role}
		else
		  object_type.preferred_identifier.role_sequence.all_role_ref.map(&:role).
		  map do |role|
		    members.detect{|m| m.all_role.include?(role)}
		  end
		end
	      identified_by_roles identifying_roles
	    end
	  else
	    value_type_declaration object_type
	  end

	forward_declarations +
	"#{supertype_definition}" +
	class_prelude(object_type, supertype) +
	  type_declaration +
	  members.
	  map do |component|
	    (@comments ? comment(component) + "\n" : '') +
	    role_definition(component)
	  end*'' +
	class_finale(object_type)
      end

      def role_definition component
	"REVISIT: override role_definition\n"
      end

      def comment component
	if component.is_a?(MM::Absorption)
	  component.parent_role.fact_type.reading_preferably_starting_with_role(component.parent_role).expand([], false)
	else
	  component.name
	end
      end

      MM = ActiveFacts::Metamodel
    end
  end
end
