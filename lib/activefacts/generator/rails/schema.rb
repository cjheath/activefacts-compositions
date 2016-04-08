#
#       ActiveFacts Rails Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/compositions/traits/rails'

module ActiveFacts
  module Generators
    module Rails
      class Schema
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

        def generate

          models
        end

        def generate
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
              "ActiveRecord::Schema.define(:version => #{Time.now.strftime('%Y%m%d%H%M%S')}) do",
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
                *@foreign_keys,
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

        def generate_columns composite
          composite.mapping.all_leaf.flat_map do |component|

=begin
            if pk.size == 1 && pk[0] == column
              case rails_type
              when 'serial'
                rails_type = "primary_key"
              when 'uuid'
                rails_type = "uuid, :default => 'gen_random_uuid()', :primary_key => true"
              end
            else
              case rails_type
              when 'serial'
                rails_type = 'integer'        # An integer foreign key
              end
            end
=end

            if component.is_a?(MM::Mapping) and
              supertype = component.object_type and
              supertype.is_a?(MM::ValueType)
              # Extract length and scale. REVISIT: Should share code with SQL
              begin
                object_type = supertype
                length ||= object_type.length
                scale ||= object_type.scale
                unless component.parent.parent and component.parent.foreign_key
                  # No need to enforce value constraints that are already enforced by a foreign key
                  value_constraint ||= object_type.value_constraint
                end
              end while supertype = object_type.supertype
              length_option = length ? ", limit: #{length}" : ''
              scale_option = scale ? ", limit: #{scale}" : ''
            else
              length_option = scale_option = ''
            end

            rails_type = 'string'
            null_option = ", null: #{!component.path_mandatory}"

            (@option_include_comments ? ["    \# #{component.comment}"] : []) +
            [%Q{    t.column "#{component.column_name.snakecase}", :#{rails_type}#{length_option}#{scale_option}#{null_option}}]
          end
        end

        def generate_composite composite
          ar_table_name = composite.mapping.rails.name

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

          create_table = %Q{  create_table "#{ar_table_name}", :id => false, :force => true do |t|}
          columns = generate_columns composite

          unless @option_exclude_fks
            composite.all_foreign_key_as_source_composite.each do |fk|
              from_column_names = fk.all_foreign_key_field.map{|fxf| fxf.component.column_name.snakecase}
              to_column_names = fk.all_index_field.map{|ixf| ixf.component.column_name.snakecase}

              @foreign_keys.concat(
                if (from_column_names.length == 1)
                  index_name = ACTR::name_trunc("index_#{ar_table_name}_on_#{from_column_names[0]}")
                  [
                    "    add_foreign_key :#{ar_table_name}, :#{fk.composite.mapping.rails.name}, :column => :#{from_column_names[0]}, :primary_key => :#{to_column_names[0]}, :on_delete => :cascade",
                    # Index it non-uniquely only if it's not unique already:
                    fk.absorption && fk.absorption.child_role.is_unique ? nil :
                      "    add_index :#{ar_table_name}, [:#{from_column_names[0]}], :unique => false, :name => :#{index_name}"
                  ].compact
                else
                  [ ]
                end
              )
            end
          end

          index_texts = []
          composite.all_index.each do |index|
            next if index.composite_as_primary_index && index.all_index_field.size == 1   # We've handled this already

            index_column_names = index.all_index_field.map{|ixf| ixf.component.column_name.snakecase}
            index_name = ACTR::name_trunc("index_#{ar_table_name}_on_#{index_column_names*'_'}")

            index_texts << '' if index_texts.empty?
            index_texts << %Q{  add_index "#{ar_table_name}", #{index_column_names.inspect}, :name => :#{index_name}#{
              index.is_unique ? ", :unique => true" : ''
            }}
          end

          [
            create_table,
            *columns,
            "  end",
            *index_texts
          ]*"\n"+"\n"
        end

        MM = ActiveFacts::Metamodel
      end
    end
    publish_generator Rails::Schema
  end
end

