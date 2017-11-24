#
#       ActiveFacts Standard SQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
# Reserved words for various versions of the standard gathered from:
# http://developer.mimer.se/validator/sql-reserved-words.tml
# https://www.postgresql.org/docs/9.5/static/sql-keywords-appendix.html
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/compositions'
require 'activefacts/compositions/names'
require 'activefacts/generator'
require 'activefacts/generator/traits/sql'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore
    class SQL
      include Traits::SQL
      extend Traits::SQL

      def initialize composition, options = {}
        @composition = composition
        process_options options
      end

      def generate
        @tables_emitted = {}
        @delayed_foreign_keys = []

        @composite_list = @composition.all_composite.sort_by{|composite| composite.mapping.name}
        if @restrict
          @composite_list.select!{|composite| g = composite.composite_group and g.name == @restrict}
        end

        generate_schema +
        @composite_list.map{|composite| generate_table composite}*"\n" + "\n" +
        @delayed_foreign_keys.sort*"\n"
      end

      def generate_schema
        schema_prefix
      end

      def generate_table composite
        @tables_emitted[composite] = true
        delayed_indices = []

        "CREATE TABLE #{safe_table_name composite} (\n" +
        (
          composite.mapping.all_leaf.flat_map do |leaf|
            # Absorbed empty subtypes appear as leaves
            next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

            generate_column leaf
          end +
          composite.all_index.map do |index|
            generate_index index, delayed_indices
          end.compact.sort +
          composite.all_foreign_key_as_source_composite.map do |fk|
            next nil if @fks == false
            fk_text = generate_foreign_key fk
            if !@delay_fks and  # We're not delaying foreign keys unnecessarily
                @tables_emitted[fk.composite] ||          # Already done
                !@composite_list.include?(fk.composite)   # Not going to be done
              fk_text
            else
              @delayed_foreign_keys <<
                go("ALTER TABLE #{safe_table_name fk.source_composite}\n\tADD " + fk_text)
              nil
            end
          end.compact.sort +
          composite.all_local_constraint.map do |constraint|
            '-- '+constraint.inspect    # REVISIT: Emit local constraints
          end
        ).compact.flat_map{|f| "\t#{f}" }*",\n"+"\n" +
        go(")") +
        delayed_indices.sort.map do |delayed_index|
          go delayed_index
        end*"\n"
      end

      def generate_column leaf
        column_name = safe_column_name(leaf)
        padding = " "*(column_name.size >= 40 ? 1 : 40-column_name.size)
        constraints = leaf.all_leaf_constraint

        "-- #{leaf.comment}\n" +
        "\t#{column_name}#{padding}#{column_type leaf, column_name}"
      end

      def column_type component, column_name
        type_name, options = component.data_type(data_type_context)
        options ||= {}
        length = options[:length]
        value_constraint = options[:value_constraint]
        type_name, length = normalise_type(type_name, length, value_constraint, options)

        "#{
          type_name
        }#{
          "(#{length}#{(s = options[:scale]) ? ", #{s}" : ''})" if length
        }#{
          ((options[:mandatory] ? ' NOT' : '') + ' NULL') if options.has_key?(:mandatory)
        }#{
          options[:default] || ''
        }#{
          auto_increment_modifier if a = options[:auto_assign] && a != 'assert'
        }#{
          check_clause(column_name, value_constraint) if value_constraint
        }"
      end

      def generate_index index, delayed_indices
        nullable_columns =
          index.all_index_field.select do |ixf|
            !ixf.component.path_mandatory
          end
        contains_nullable_columns = nullable_columns.size > 0

        # The index can only be emitted as PRIMARY if it has no nullable columns:
        primary = index.composite_as_primary_index && !contains_nullable_columns

        column_names =
          index.all_index_field.map do |ixf|
            column_name(ixf.component)
          end

        if index.is_unique
          if contains_nullable_columns and @closed_world_indices
            # Implement open-world uniqueness using a filtered index:
            table_name = safe_table_name(index.composite)
            delayed_indices <<
              'CREATE UNIQUE'+index_kind(index)+' INDEX '+
              escape("#{table_name(index.composite)}By#{column_names*''}", index_name_max) +
              " ON #{table_name}("+column_names.map{|n| escape(n, column_name_max)}*', ' +
              ") WHERE #{
                nullable_columns.
                map{|ixf| safe_column_name ixf.component}.
                map{|column_name| column_name + ' IS NOT NULL'} *
                ' AND '
              }"
            nil
          else
            '-- '+index.inspect + "\n\t" +
            (primary ? 'PRIMARY KEY' : 'UNIQUE') +
            index_kind(index) +
            "(#{column_names.map{|n| escape(n, column_name_max)}*', '})"
          end
        else
          # REVISIT: If the fields of this index is a prefix of another index, it can be omitted
          delayed_indices <<
            'CREATE'+index_kind(index)+' INDEX '+
            escape("#{table_name(index.composite)}By#{column_names*''}", index_name_max) +
            " ON #{table_name}(" +
            column_names.map{|n|
              escape(n, column_name_max)
            }*', ' +
            ')'
          nil
        end
      end

      def generate_foreign_key fk
        '-- '+fk.inspect
        "FOREIGN KEY (" +
          fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
          ") REFERENCES #{safe_table_name fk.composite} (" +
          fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
        ")"
      end
    end

    publish_generator SQL
  end
end
