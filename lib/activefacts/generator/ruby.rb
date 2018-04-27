#
#       ActiveFacts Ruby API Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/generator/oo'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    class Ruby < ObjectOriented
      def self.options
        super.merge(
          {
            scope: [String, "Generate a Ruby module that's nested inside the module you name here"]
          }
        )
      end

      def initialize composition, options = {}
        super
        @scope = options.delete('scope') || ''
        @scope = @scope.split(/::/)
        @scope_prefix = '  '*@scope.size
      end

      def prelude composition
        "require 'activefacts/api'\n\n" +
        (0...@scope.size).map{|i| '  '*i + "module #{@scope[i]}\n"}*'' +
        "#{@scope_prefix}module #{composition.name.words.capcase}\n"
      end

      def finale
        @scope.size.downto(0).map{|i| '  '*i+"end\n"}*''
      end

      def generate_classes composites
        super(composites).
          gsub(/^/, '  '*@scope.size)
      end

      def identified_by_roles identifying_roles
        "    identified_by   #{ identifying_roles.map{|m| ':'+ruby_role_name(m) }*', ' }\n"
      end

      def value_type_declaration object_type
        "    value_type#{object_type.length ? "      length: #{object_type.length}" : ''}\n"    # REVISIT: Add other parameters and value restrictions
      end

      def class_prelude(object_type, supertype)
        global_qualifier = object_type == supertype ? '::' :''
        "  class #{object_type.name.words.capcase}" + (supertype ? " < #{global_qualifier}#{supertype.name.words.capcase}" : '') + "\n"
      end

      def class_finale(object_type)
        "  end\n"
      end

      def role_definition component
        role_name = ruby_role_name component

        # Is the role mandatory?
        mandatory = component.is_mandatory ? ', mandatory: true' : ''

        # Does the role name imply the matching class name?
        if component.is_a?(MM::Absorption) and
            counterpart = component.object_type and
            counterpart_composite = composite_for(counterpart)
          counterpart_class_emitted = @composites_finished[counterpart_composite]

          counterpart_class_name = ruby_class_name counterpart_composite
          counterpart_default_role = ruby_role_name counterpart_composite.mapping
          rolename_implies_class = role_name.words.capcase == counterpart_class_name
          class_ref = counterpart_class_emitted ? counterpart_class_name : counterpart_class_name.inspect
          class_spec = rolename_implies_class ? '' : ", class: #{class_ref}"

          # Does the reverse role need explicit specification?
          implied_reverse_role_name = ruby_role_name(component.root.mapping)
          actual_reverse_role_name = ruby_role_name(component.reverse_mapping || component.forward_mapping)

          if implied_reverse_role_name != actual_reverse_role_name
            counterpart_spec = ", counterpart: :#{actual_reverse_role_name}"
          elsif !rolename_implies_class
            # _as_XYZ is added where the forward role does not imply the class, and :counterpart role name is not specified
            actual_reverse_role_name += "_as_#{role_name}"
          end
          all = component.child_role.is_unique ? '' : 'all_'
          see = ", see #{counterpart_class_name}\##{all+actual_reverse_role_name}"
        end

        counterpart_comment = "# #{comment component}#{see}"

        definition =
          "    #{role_specifier component}"
        definition += ' '*(20-definition.length) if definition.length < 20
        definition += ":#{ruby_role_name component}#{mandatory}#{class_spec}#{counterpart_spec}  "
        definition += ' '*(56-definition.length) if definition.length < 56
        definition += "#{counterpart_comment}"
        definition += "\n"
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
        super
      end
    end
    publish_generator Ruby, "Generate Ruby code for fact-based programming with the activefacts-api. Use the binary compositor"
  end
end
