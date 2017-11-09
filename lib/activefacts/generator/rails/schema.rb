#
#       ActiveFacts Rails Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/compositions/traits/rails'

module ActiveFacts
  module Generators
    module Rails
      class Schema
        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
        HEADER = "# Auto-generated from CQL, edits will be lost"
        def self.options
          ({
            exclude_fks:      ['Boolean', "Don't generate foreign key definitions"],
            include_comments: ['Boolean', "Generate a comment for each column showing the absorption path"],
            closed_world:     ['Boolean', "Set this if your DBMS only allows one null in a unique index (MS SQL)"],
          })
        end

        def initialize composition, options = {}
          @composition = composition
          @options = options
          @option_exclude_fks = options.delete("exclude_fks")
          @option_include_comments = options.delete("include_comments")
          @option_closed_world = options.delete("closed_world")
        end

        def warn *a
          $stderr.puts *a
        end

        def data_type_context
          @data_type_context ||= RailsDataTypeContext.new
        end

        def generate
          @indexes_generated = {}
          @foreign_keys = []
          # If we get index names that need to be truncated, add a counter to ensure uniqueness
          @dup_id = 0

          tables =
            @composition.
            all_composite.
            sort_by{|composite| composite.mapping.name}.
            map{|composite| generate_composite composite}.
            compact

          header =
            [
              '#',
              "# schema.rb auto-generated for #{@composition.name}",
              '#',
              '',
              "ActiveRecord::Base.logger = Logger.new(STDOUT)",
              "ActiveRecord::Schema.define(version: #{Time.now.strftime('%Y%m%d%H%M%S')}) do",
              "  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')",
              '',
            ]
          foreign_keys =
            if @option_exclude_fks
              [
                'end'
              ]
            else
              [
                '  unless ENV["EXCLUDE_FKS"]',
                *@foreign_keys.sort,
                '  end',
                'end'
              ]
            end

          (
            header +
            tables +
            foreign_keys
          )*"\n"+"\n"
        end

        def generate_composite composite
          ar_table_name = composite.rails.plural_name

          pi = composite.primary_index
          unless pi
            warn "Warning: Cannot generate schema for #{composite.mapping.name} because it has no primary key"
            return nil
          end
          pk = composite.primary_index.all_index_field.to_a
          if pk[0].component.is_auto_assigned
            identity_column = pk[0].component
            warn "Warning: redundant column(s) after #{identity_column.name} in primary key of #{ar_table_name}" if pk.size > 1
          end

          # Detect if this table is a join table.
          # Join tables have multi-part primary keys that are made up only of foreign keys
          is_join_table = pk.length > 1 and
            !pk.detect do |pk_field|
              pk_field.component.all_foreign_key_field.size == 0
            end
          warn "Warning: #{table.name} has a multi-part primary key" if pk.length > 1 and !is_join_table

          create_table = %Q{  create_table "#{ar_table_name}", id: false, force: true do |t|}
          columns = generate_columns composite

          index_texts = []
          composite.all_index.each do |index|
            next if index.composite_as_primary_index && index.all_index_field.size == 1   # We've handled this already

            index_column_names = index.all_index_field.map{|ixf| ixf.component.column_name.snakecase}
            index_name = ACTR::name_trunc("index_#{ar_table_name}_on_#{index_column_names*'_'}")

            index_texts << '' if index_texts.empty?

            all_mandatory = index.all_index_field.to_a.all?{|ixf| ixf.component.path_mandatory}
            @indexes_generated[index] = true
            index_texts << %Q{  add_index "#{ar_table_name}", #{index_column_names.inspect}, name: :#{index_name}#{
              # Avoid problems with closed-world uniqueness: only all_mandatory indices can be unique on closed-world index semantics (MS SQL)
              index.is_unique && (!@option_closed_world || all_mandatory) ? ", unique: true" : ''
            }}
          end

          unless @option_exclude_fks
            composite.all_foreign_key_as_source_composite.each do |fk|
              from_column_names = fk.all_foreign_key_field.map{|fxf| fxf.component.column_name.snakecase}
              to_column_names = fk.all_index_field.map{|ixf| ixf.component.column_name.snakecase}

              @foreign_keys.concat(
                if (from_column_names.length == 1)

                  # See if the from_column already has an index (not necessarily unique, but the column must be first):
                  from_index_needed =
                    fk.
                    all_foreign_key_field.
                    single.
                    component.        # See whether the foreign key component
                    all_index_field.  # occurs in a unique index already
                    select do |ixf|
                      ixf.access_path.is_a?(Metamodel::Index) &&    # It's an Index, not an FK
                      ixf.ordinal == 0                              # It's first in this index
                    end
                  already_indexed = from_index_needed.any?{|ixf| @indexes_generated[ixf.access_path]}
                  is_one_to_one = fk.absorption && fk.absorption.child_role.is_unique

                  index_name = ACTR::name_trunc("index_#{ar_table_name}_on_#{from_column_names[0]}")
                  [
                    "    add_foreign_key :#{ar_table_name}, :#{fk.composite.mapping.rails.plural_name}, column: :#{from_column_names[0]}, primary_key: :#{to_column_names[0]}, on_delete: :cascade",
                    # Index it non-uniquely only if it's not unique already:
                    if already_indexed or is_one_to_one  # Either it already is, or it will be indexed, no new index needed
                      nil
                    else
                      "    add_index :#{ar_table_name}, [:#{from_column_names[0]}], unique: false, name: :#{index_name}"
                    end
                  ].compact
                else
                  [ ]
                end
              )
            end
          end

          [
            create_table,
            *columns,
            "  end",
            *index_texts.sort
          ]*"\n"+"\n"
        end

        def generate_columns composite
          composite.mapping.all_leaf.flat_map do |component|
            # Absorbed empty subtypes appear as leaves
            next [] if component.is_a?(MM::Absorption) && component.parent_role.fact_type.is_a?(MM::TypeInheritance)
            generate_column component
          end
        end

        def generate_column component
          type_name, options = component.data_type(data_type_context)
          options ||= {}
          length = options[:length]
          value_constraint = options[:value_constraint]
          type, type_name = *normalise_type(type_name)

          if pkxf = component.all_index_field.detect{|ixf| (a = ixf.access_path).is_a?(MM::Index) && a.composite_as_primary_index }
            auto_assign = options[:auto_assign]
            case type_name
            when 'integer'
              type_name = 'primary_key' if auto_assign
              @indexes_generated[pkxf.access_path] = true
            when 'uuid'
              type_name = "uuid"
              if auto_assign
                type_name += ", default: 'gen_random_uuid()', primary_key: true"
                @indexes_generated[pkxf.access_path] = true
              end
            end
          end

          valid_parameters = MM::DataType::TypeParameters[type]
          length_ok = valid_parameters &&
            ![MM::DataType::TYPE_Real, MM::DataType::TYPE_Integer].include?(type) &&
            (valid_parameters.include?(:length) || valid_parameters.include?(:precision))
          scale_ok = length_ok && valid_parameters.include?(:scale)
          length_option = length_ok && options[:length] ? ", limit: #{options[:length]}" : ''
          scale_option = scale_ok && options[:scale] ? ", scale: #{options[:scale]}" : ''
          null_option = ", null: #{!options[:mandatory]}"

          (@option_include_comments ? ["    \# #{component.comment}"] : []) +
          [%Q{    t.column "#{component.column_name.snakecase}", :#{type_name}#{length_option}#{scale_option}#{null_option}}]
        end

        class RailsDataTypeContext < MM::DataType::Context
          def integer_ranges
            [
              ['integer', -2**63, 2**63-1]
            ]
          end

          def default_length data_type, type_name
            case data_type
            when MM::DataType::TYPE_Real
              53        # IEEE Double precision floating point
            when MM::DataType::TYPE_Integer
              63
            else
              nil
            end
          end

          def default_surrogate_length
            64
          end

          def boolean_type
            'boolean'
          end

          def surrogate_type
            type_name, = choose_integer_type(0, 2**(default_surrogate_length-1)-1)
            type_name
          end

          def valid_from_type
            date_time_type
          end

          def date_time_type
            'datetime'
          end

          def default_char_type
            'string'
          end

          def default_varchar_type
            'string'
          end

          def default_text_type
            default_varchar_type
          end
        end

        # Return SQL type and (modified?) length for the passed base type
        def normalise_type type_name
          type = MM::DataType.normalise(type_name)

          [
            type,
            case type
            when MM::DataType::TYPE_Boolean;  'boolean'
            when MM::DataType::TYPE_Integer;  'integer'
            when MM::DataType::TYPE_Real;     'float'
            when MM::DataType::TYPE_Decimal;  'decimal'
            when MM::DataType::TYPE_Money;    'decimal'
            when MM::DataType::TYPE_Char;     'string'
            when MM::DataType::TYPE_String;   'string'
            when MM::DataType::TYPE_Text;     'text'
            when MM::DataType::TYPE_Date;     'datetime'
            when MM::DataType::TYPE_Time;     'time'
            when MM::DataType::TYPE_DateTime; 'datetime'
            when MM::DataType::TYPE_Timestamp;'datetime'
            when MM::DataType::TYPE_Binary;
              if type_name =~ /^([Gu]uid|uniqueidentifier)$/i
                'uuid'
              else
                'binary'
              end
            else
              type_name
            end
          ]
        end

      end
    end
    publish_generator Rails::Schema
  end
end

