#
#       ActiveFacts Tranformation Rule Stub Generator
#
# Copyright (c) 2017 Factil Pty Ltd. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/compositions'
require 'activefacts/compositions/names'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    class TransRegen
      INDENT = "    "
      def self.options
        {
        }
      end

      def initialize compositions, options = {}
        @composition = compositions[0]
        @options = options
      end

      def generate
        @constellation = @composition.constellation
        @transform_topic = @constellation.Topic.values.select{|t| t.all_import_as_precursor_topic.size == 0}.first
        if !@constellation.Vocabulary.values.to_a[0].is_transform
          raise "Expected input file to be transform"
        end

        source_imports = @constellation.Import.values.select{|imp| imp.topic == @transform_topic && imp.import_role == "source"}
        target_imports = @constellation.Import.values.select{|imp| imp.topic == @transform_topic && imp.import_role == "target"}

        composite_list = @composition.all_composite.select do |composite|
          target_imports.detect do |imp|
            imp.precursor_topic.all_concept.detect{|c| c.object_type == composite.mapping.object_type}
          end
        end.sort_by{|composite| composite.mapping.name}

        generate_header(source_imports, target_imports) +
        composite_list.map{|composite| generate_transform_rule composite}*"\n" + "\n"
      end

      def generate_header source_imports, target_imports
        "transform #{@transform_topic.topic_name};\n" +
        "\n" +
        source_imports.map{|imp| "import source #{imp.precursor_topic.topic_name};"} * "\n" + "\n" +
        target_imports.map{|imp| "import target #{imp.precursor_topic.topic_name};"} * "\n" + "\n" +
        "\n"
      end

      def generate_transform_rule composite
        existing_rules = @transform_topic.all_concept.select do |concept|
          tr = concept.transform_rule and
            tr.compound_transform_matching.all_transform_target_ref.to_a[0].target_object_type == composite.mapping.object_type
        end.map {|concept| concept.transform_rule}

        if existing_rules.size > 0
          existing_rules.map{|tr| regenerate_transform_rule(composite, tr)} * "\n\n"
        else
          generate_new_transform_rule(composite)
        end
      end

      def indent text, level
        INDENT * level + text
      end

      def leading_hyphenate leading_adjective
        words = leading_adjective.words
        if words.size == 1
          leading_adjective + '-'
        else
          words[0] + '- ' + words[1..-1].join(' ')
        end
      end

      def trailing_hyphenate trailing_adjective
        words = trailing_adjective.words
        if words.size == 1
          '-' + trailing_adjective
        else
          words[0...-1].join(' ') + ' -' + words[-1]
        end
      end

      def full_role_name mapping
        if mapping.is_a?(ActiveFacts::Metamodel::Absorption)
          la = mapping.child_role.all_role_ref.to_a[0].leading_adjective
          ta = mapping.child_role.all_role_ref.to_a[0].trailing_adjective
          (la ? leading_hyphenate(la) + ' ' : '') + mapping.object_type.name + (ta ? ' ' + trailing_hyphenate(ta) : '')
        else
          mapping.object_type.name
        end
      end

      #
      # New transform rule
      #
      def generate_new_transform_rule composite
        generate_compound_transform_matching(composite.mapping, 0, '') + ";\n"
      end

      def generate_transform_matching mapping, level, prefix
        if mapping.object_type.is_a?(ActiveFacts::Metamodel::ValueType)
          generate_simple_transform_matching(mapping, level, prefix)
        else
          generate_compound_transform_matching(mapping, level, prefix)
        end
      end

      def generate_simple_transform_matching mapping, level, prefix
        full_name = full_role_name(mapping)
        prefixed_name = (prefix.size > 0 ? prefix + ' . ' : '') + full_name
        indent("#{prefixed_name} <-- /* EXPR */", level)
      end

      def generate_compound_transform_matching mapping, level, prefix
        members = mapping.all_member.sort_by(&:ordinal).flatten
        prefixed_name = (prefix.size > 0 ? prefix + ' . ' : '') + full_role_name(mapping)
        if members.size == 1
          generate_transform_matching(members[0], level, prefixed_name)
        else
          indent("#{prefixed_name} <== /* OBJECT TYPE or QUERY */ {\n", level) +
          members.map do |m|
            generate_transform_matching(m, level + 1, '')
          end * ",\n" + "\n" +
          indent("}", level)
        end
      end

      #
      # Regenerate existing transform rule
      #
      def regenerate_transform_rule(composite, transform_rule)
        # regenerate_compound_transform_matching(composite.mapping, 0, '') + ";\n"
      end
    end
    publish_generator TransRegen
  end
end
