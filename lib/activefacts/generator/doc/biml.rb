#
#       ActiveFacts BIML Generator
#
# This generator produces an BIML-formated model of a Composition.
#
# Copyright (c) 2018 Factil Pty Ltd. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/generator/traits/biml'
require 'activefacts/support'

module ActiveFacts
  module Generators
    module Doc
      class BIML
        include Traits::BIML
        extend Traits::BIML

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)

        def initialize composition, options = {}
          @composition = composition
          @vocabulary = @composition.constellation.Vocabulary.values[0]      # REVISIT when importing from other vocabularies
          process_options options
        end

        def generate
          trace.enable 'biml'

          generate_header +
          generate_tables(1) +
          generate_footer
        end

        def indent depth, str
          "  " * depth + str + "\n"
        end

        def generate_header
          "<Biml xmlns=\"http://schemas.varigence.com/biml.xsd\">\n" +
          "  <Databases>\n" +
          "    <Database Name=\"#{@vocabulary.name}\"/>\n" +
          "  </Databases>\n"
        end

        def generate_footer
          "</Biml>\n"
        end

        def generate_tables depth
          indent(depth, "<Tables>") +
          @composition.all_composite.sort_by{|composite| composite.mapping.name}.map do |composite|
            generate_table(depth+1, composite)
          end *"\n" + "\n" +
          indent(depth, "</Tables>")
        end

        def generate_table depth, table
          name = table_name(table)
          delayed_indices = []
          schema_name = "#{@vocabulary.name}.[default]"
          full_table_name = "#{schema_name}.#{name}"

          table_start = indent(depth, "<Table Name=\"#{name}\" SchemaName=\"#{schema_name}\">")
          table_columns = generate_columns(depth+1, table, schema_name)
          table_keys = generate_keys(depth+1, table)
          table_indexes = generate_indexes(depth+1, table)
          table_end = indent(depth, "</Table>")

          table_start + table_columns + table_keys + table_indexes + table_end
        end

        def generate_columns depth, table, schema_name
          columns_start = indent(depth, "<Columns>")
          normal_columns = generate_normal_columns(depth, table)
          table_references = generate_table_references(depth, table, schema_name)
          columns_end = indent(depth, "</Columns>")

          columns_start + normal_columns + table_references + columns_end
        end

        def generate_normal_columns depth, table
          table.mapping.all_leaf.flat_map.sort_by{|c| column_name(c)}.map do |leaf|
            # Absorbed empty subtypes appear as leaves
            next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)
            next if leaf.all_foreign_key_field.size > 0

            generate_column(depth+1, leaf)
          end.compact * ''
        end

        def generate_column depth, component
          column_name = safe_column_name(component)

          is_nullable = component.path_mandatory ? "false" : "true"
          constraints = component.all_leaf_constraint

          type_name, options = component.data_type(data_type_context)
          options ||= {}
          value_constraint = options[:value_constraint]
          type_name = choose_sql_type(type_name, value_constraint, component, options)
          length = options[:length]
          scale = options[:scale]
          precision = options[:precision]

          type_params =
            (length ? "Length=\"#{length}\" " : '') +
            (scale ? "Scale=\"#{scale}\" " : '') +
            (precision ? "Precision=\"#{precision}\" " : '')

          indent(depth,
            "<Column Name=\"#{column_name}\ IsNullable=\"#{is_nullable}\" DataType=\"#{type_name}\" #{type_params}/>"
          )
        end

        def generate_keys depth, table
          if table.all_index.size > 0
            name = table_name(table)
            indent(depth, "<Keys>") +
              table.all_index.map do |index|
                generate_key(depth+1, index, name)
              end * "" +
            indent(depth, "</Keys>")
          else
            ''
          end
        end

        def generate_key depth, index, table_name
          nullable_columns =
            index.all_index_field.select do |ixf|
              !ixf.component.path_mandatory
            end
          contains_nullable_columns = nullable_columns.size > 0

          primary = index.composite_as_primary_index && !contains_nullable_columns

          key_type = primary ? 'PrimaryKey' : 'UniqueKey'
          if primary
            key_name = "PK_#{table_name}"
          else
            key_name = "UK_#{table_name}_#{index.all_index_field.map { |ixf| ixf.component.name} * '_'}"
          end

          indent(depth, "<#{key_type} Name=\"#{key_name}\">") +
          indent(depth+1, "<Columns>") +
          index.all_index_field.map do |ixf|
            indent(depth+2, "<Column ColumnName=\"#{ixf.component.name}\"/>")
          end * "" +
          indent(depth+1, "</Columns>") +
          indent(depth, "</#{key_type}>")
        end

        def generate_indexes depth, table
          ''
        end

        def generate_index depth, index, table_name
        end

        def generate_table_references depth, table, schema_name
          foreign_keys =
            table.all_foreign_key_as_source_composite.sort_by do |fk|
              [fk.source_composite.mapping.name, fk.mapping.inspect]
            end
          output = ''
          for i in 0..(foreign_keys.size - 1)
            fk = foreign_keys[i]
            group_name = "#{table_name(table)}#{i}"
            output += generate_table_reference(depth+1, fk, schema_name, group_name)
          end
          output
        end

        def generate_table_reference depth, fk, schema_name, group_name
          if fk.all_foreign_key_field.size == 1
            fkf = fk.all_foreign_key_field[0]
            ixf = fk.all_index_field[0]
            column_name = safe_column_name(fkf.component)
            full_source_table_name = "#{schema_name}.#{table_name(fk.source_composite)}"
            indent(depth, "<TableReference Name=\"#{column_name}\" TableName=\"#{full_source_table_name}\" />")
          else
            output = ''
            for i in 0..(fk.all_foreign_key_field.size - 1)
              fkf = fk.all_foreign_key_field[i]
              ixf = fk.all_index_field[i]
              column_name = safe_column_name(fkf.component)
              foreign_column_name = safe_column_name(ixf.component)
              output += indent(depth,
                  "<MultipleColumnTableReference Name=\"#{column_name}\" ForeignColumnName=\"#{foreign_column_name}\" " +
                  "MultipleColumnTableReferenceGroupName=\"#{group_name}\" />"
                )
            end
            output
          end
        end
      end
    end

    publish_generator Doc::BIML
  end
end
