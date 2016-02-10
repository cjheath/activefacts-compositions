#
#       ActiveFacts Ruby API Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generators'
require 'activefacts/generators/oo'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    class Ruby < ObjectOriented
      def initialize composition, options = {}
	super
      end

      def prelude composition
	"require 'activefacts/api'\n" +
	  "\nmodule #{composition.name}\n"
      end

      def finale
	'end'
      end

      def identified_by_roles identifying_roles
	"    identified_by #{ identifying_roles.map{|m| ':'+ruby_role_name(m) }*', ' }\n"
      end

      def value_type_declaration object_type
	"    value_type#{object_type.length ? " :length => #{object_type.length}" : ''}\n"	# REVISIT: Add other parameters and value restrictions
      end

      def class_prelude(object_type, supertype)
	"  class #{object_type.name.words.capcase}" + (supertype ? " < #{supertype.name.words.capcase}" : '') + "\n"
      end

      def class_finale(object_type)
	"  end\n"
      end

      def role_definition component
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
	'    # ' + super
      end
    end
    publish_generator Ruby
  end
end
