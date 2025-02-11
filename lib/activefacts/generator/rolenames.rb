#
#       ActiveFacts Rolenames Generator
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
    class RoleNames
      def self.options
        {
          # comments: ['Boolean', "Preceed each role definition with a comment that describes it"]
        }
      end

      def self.compatibility
        [1, %i{binary}]
      end

      def initialize constellation, composition, options = {}
        @constellation = constellation
        @composition = composition
        @options = options
        # @comments = @options.delete("comments")
      end

      def generate
        composites =
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}.
          flat_map{|composite| generate_class(composite) }.
          compact.
          join("\n").
          gsub(/[   ][  ]*$/, '')
      end

      def generate_class composite
        mapping = composite.mapping
        object_type = mapping.object_type

        mapping.re_rank
        members = mapping.
          all_member.
          sort_by{|m| m.ordinal}

        member_names = members.map do |member|
          far_role_name(member) # + '('+member.inspect+')'
        end

        # REVISIT: Check unique names
        if member_names.uniq.size < member_names.size
          raise "duplicate names for members of #{object_type.name}: #{member_names*', '}"
        end

        object_type.name + " {\n" +
          member_names.map{|n| "\t#{n}\n"}*'' +
        "}"
      end

      def far_role_name component
        role_name = component.name

        if component.is_a?(Metamodel::Absorption)
          if object_role = component.parent_role and object_role.name != object_role.object_type.name
            role_name += "(as #{object_role.name})"
          elsif object_role.fact_type.is_a?(Metamodel::TypeInheritance)
            role_name = "(as #{role_name})"
          end
        end

        definition = role_name
      end

    end

    publish_generator RoleNames, "Generate a list of every object type with its role names. Use the binary compositor"
  end
end
