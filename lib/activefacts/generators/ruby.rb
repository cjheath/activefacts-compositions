#
#       ActiveFacts Ruby API Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generators'

# require 'activefacts/generators/traits/ruby'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    class Ruby
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
      def retract_intrinsic_types
	@composition.
        all_composite.
        sort_by{|composite| composite.mapping.name}.
	each do |composite|
	  o = composite.mapping.object_type
	  next unless o.is_a?(MM::ValueType)
	  composite.retract and next if o.name == "_ImplicitBooleanValueType" or !o.supertype
	end
      end

      def prelude composition
	"require 'activefacts/api'\n" +
	  "\nmodule #{composition.name}\n"
      end

      def finale
	'end'
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

	# Select the members that will be declared as Ruby roles:
	members = mapping.all_member.reject{|m| m.is_a?(MM::Absorption) && m.forward_absorption}

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
	      ''
	    else
	      identifying_role_names =
		object_type.preferred_identifier.role_sequence.all_role_ref.map(&:role).
		map do |role|
		  members.detect{|m| m.all_role.include?(role)}
		end.
		map{|m| ':'+ruby_role_name(m) }
	      "    identified_by #{identifying_role_names*', '}\n"
	    end
	  else
	    "    value_type#{object_type.length ? " :length => #{object_type.length}" : ''}\n"	# REVISIT: Add other parameters and value restrictions
	  end

	forward_declarations +
	"#{supertype_definition}" +
	"  class #{object_type.name.words.capcase}" + (supertype ? " < #{supertype.name.words.capcase}" : '') + "\n" +
	  type_declaration +
	  members.
	  map do |component|
	    (@comments ? comment(component) + "\n" : '') +
	    ruby_role(component)
	  end*'' +
	"  end\n"
      end

      def ruby_role component
	role_name = ruby_role_name component

	# Does the role name imply the matching class name?
	if component.is_a?(MM::Mapping) and
	    target = component.object_type and
	    target_composite = composite_for(target)
	  class_emitted = @composites_emitted[target_composite]
	  class_name = ruby_class_name target_composite
	  implied_class_name = role_name.words.capcase
	  rolename_implies_class = implied_class_name == class_name
	  class_ref = rolename_implies_class ? '' : ", :class => #{class_emitted ? class_name : class_name.inspect}"
	end

	# REVISIT: Does the reverse role need explicit specification?

	"    #{role_specifier component} :#{component.name.words.snakecase}#{class_ref}\n"
      end

      def role_specifier component
	if component.is_a?(MM::Indicator)
	  'maybe'
	else
	  if component.is_a?(MM::Absorption) and component.child_role.is_unique
	    'one_to_one'
	  else
	    'has_one'
	  end
	end
      end

      def ruby_role_name component
	component.name.words.snakecase
      end

      def ruby_class_name composite
	composite.mapping.name.words.capcase
      end

      def comment component
	'    # ' +
	if component.is_a?(MM::Absorption)
	  component.parent_role.fact_type.reading_preferably_starting_with_role(component.parent_role).expand([], false)
	else
	  component.name
	end
      end

      MM = ActiveFacts::Metamodel
    end
    publish_generator Ruby
  end
end
