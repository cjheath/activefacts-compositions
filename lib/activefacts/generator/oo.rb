#
#       ActiveFacts Object-Oriented API Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    class ObjectOriented
      def self.options
        {
          comments: ['Boolean', "Preceed each role definition with a comment that describes it"]
        }
      end

      def initialize composition, options = {}
        @composition = composition
        @options = options
        @comments = @options.delete("comments")
      end

      def generate
        @composites_started = {}
        @composites_finished = {}

        retract_intrinsic_types

        composites =
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}

        (prelude(@composition) +
        generate_classes(composites) +
        finale).gsub(/[   ][  ]*$/, '')
      end

      def generate_classes composites
        composites.
        map do |composite|
          generate_class(composite)
        end.
        compact.
        join("\n")
      end

      def composite_for object_type
        @composition.all_composite.detect{|c| c.mapping.object_type == object_type }
      end

      # We don't need Composites for object types that are built-in to the Ruby API.
      def is_intrinsic_type composite
        o = composite.mapping.object_type
        return true if o.name == "_ImplicitBooleanValueType"
        return false if o.supertype
        # A value type with no supertype must be emitted if it is the child in any absorption:
        return !composite.mapping.all_member.detect{|m| m.forward_mapping}
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

      def exclude_as_counterpart member
        # If emitting a role also creates its counterpart, we can exclude the counterparts.
        # This depends on the subtype, so centralise the knowledge here where it can be overridden.
        # Non-Mappings always get emitted:
        return false unless MM::Mapping === member

        # TypeInheritance always gets skipped:
        return true if MM::Absorption === member && member.child_role.fact_type.is_a?(MM::TypeInheritance)

        # Don't skip the mandatory counterpart of a one-to-one:
        return false if member.is_one_to_one and member.is_mandatory

        # Otherwise skip all reverse mappings (these have a forward mapping)
        return member.forward_mapping
      end

      def generate_class composite, precursor_to = [], predefine_role_players = true
        return nil if @composites_started[composite]
        @composites_started[composite] = true

        mapping = composite.mapping
        object_type = mapping.object_type
        is_entity_type = object_type.is_a?(MM::EntityType)
        forward_declarations = []

        # Emit supertypes before subtypes
        supertype_composites =
          object_type.all_supertype.map{|s| composite_for(s) }.compact
        forward_declarations +=
          supertype_composites.map{|c| generate_class(c, precursor_to+[composite], false)}.compact

        # Select the members that will be declared as O-O roles:
        mapping.re_rank
        members = mapping.
          all_member.
          sort_by{|m| m.ordinal}.
          reject do |m|
            exclude_as_counterpart(m)
          end

        if predefine_role_players
          # To reduce forward references, emit any classes that play a role
          # we're about to emit, unless one is a subtype of any class that
          # is currently being processed.
          forward_composites =
            members.
              select{ |m| m.is_a?(MM::Mapping) }.
              map{ |m| composite_for m.object_type }.
              reject{|c| precursor_to.detect{|p| c.mapping.object_type.supertypes_transitive.include?(p.mapping.object_type) }}.
              compact.
              sort_by{|c| c.mapping.name}
          forward_declarations +=
            forward_composites.map{|c| generate_class(c, precursor_to+[composite])}.compact
        end

        forward_declarations = forward_declarations.map{|f| "#{f}\n"}*''

        primary_supertype =
          if is_entity_type
            object_type.identifying_supertype ||
              object_type.supertypes[0] # Hopefully there's only one!
          else
            object_type.supertype || object_type
          end

        type_declaration =
          if is_entity_type
            if primary_supertype and object_type.identification_is_inherited
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

        @composites_finished[composite] = true

        forward_declarations +
        class_prelude(object_type, primary_supertype) +
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

      MM = ActiveFacts::Metamodel unless const_defined?(:MM)
    end
  end
end
