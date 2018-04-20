#
#       ActiveFacts Unified Index Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
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
    module ETL
      class Unidex

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
        def self.options
          # REVISIT: There's no way to support SQL dialect options here
          sql_trait = ActiveFacts::Generators::Traits::SQL
          Class.new.extend(sql_trait).  # Anonymous class to enable access to traits module instance methods
          options.
          merge(
            {
              dialect: [String, "SQL Dialect to use"]
            }
          )
        end

        def initialize composition, options = {}
          @composition = composition
          @options = options

          @trait = ActiveFacts::Generators::Traits::SQL
          if @dialect = options.delete("dialect")
            require 'activefacts/generator/traits/sql/'+@dialect
            trait_name = ActiveFacts::Generators::Traits::SQL.constants.detect{|c| c.to_s =~ %r{#{@dialect}}i}
            @trait = @trait.const_get(trait_name)
          end
          self.class.include @trait
          self.class.extend @trait
          extend @trait

          process_options options
        end

        def process_options options
          super
        end

        def generate
          @all_table_unions = []
          header +
          @composition.
            all_composite.
            sort_by{|c| c.mapping.name}.
            map{|c| generate_composite c}.
            concat([all_union(@all_table_unions)]).
            compact*"\n" +
          trailer
        end

        def all_union unions
          return '' if unions.empty?
          create_or_replace("#{schema_name}_unidex", 'VIEW') + " AS\n" +
          unions.compact.map{|s| "SELECT * FROM "+s } *
          "\nUNION ALL " +
          ";\n"
        end

        def header
          schema_prefix
        end

        def generate_composite composite
          return nil if composite.mapping.injection_annotation
          return nil if composite.mapping.object_type.is_static

          trace :unidex, "Generating view for #{table_name(composite)}" do
            union =
            composite.mapping.all_member.to_a.sort_by{|m| m.name}.flat_map do |member|
              next nil if member.injection_annotation
              rank_key = member.rank_key

              case key_type = rank_key[0]
              when MM::Component::RANK_SURROGATE,     # A surrogate key; these do not get indexed
                  MM::Component::RANK_DISCRIMINATOR,  # Replacement for exclusive indicators, often subtypes
                  MM::Component::RANK_MULTIPLE        # Nested absorption
                trace :unidex, "Ignoring #{MM::DataTypes::TypeNames[key_type]} #{column_name member}"
                next nil
              when MM::Component::RANK_INJECTION      # ValueField (index), ValidFrom (don't) or an Absorption with an injection annotation
                if MM::ValueField === member
                  generate_value leaf
                else
                  nil
                end
              when MM::Component::RANK_INDICATOR
                generate_indicator member
              else
                raise "Unexpected non-Absorption" unless MM::Absorption === member
                if member.foreign_key
                  # Index this record by the natural key of the FK target record, if possible
                  generate_joined_value member
                # elsif member.full_absorption  # REVISIT: Anything special to do here?
                else
                  (member.all_member.size > 0 ? member.all_leaf : [member]).flat_map do |leaf|
                    generate_value leaf
                  end
                end
              end
            end.compact * "\nUNION ALL"

            if union.size > 0
              union_name = "#{table_name(composite)}_unidex"
              @all_table_unions << union_name

              "/*\n"+
              " * View to extract unified index values for #{table_name(composite)}\n"+
              " */\n"+
              create_or_replace("#{union_name}", 'VIEW') + " AS" +
              union +
              ";\n"
            else
              ''
            end
          end
        end

        def trailer
          ''
        end

        def generate_indicator leaf
          nil # REVISIT: Do we need anything here?
          # select(leaf.root, safe_column_name(leaf), 1, column_name(leaf))
        end

        # This foreign key connects two composites (tables)
        def generate_joined_value member
          foreign_key = member.foreign_key
          # REVISIT: Is this restriction even necessary?
          return nil unless foreign_key.composite.mapping.object_type.is_static

          # Index the source table by the natural key of the target, if we can find one
          indices = foreign_key.composite.all_index
          return null if indices.empty?

          search_index_by = {}
          searchable_indices =
            indices.select do |ix|
              next false if !ix.is_unique
              non_fk_components = ix.all_index_field.map(&:component) - foreign_key.all_index_field.map(&:component)
              next unless non_fk_components.size == 1
              component = non_fk_components[0]
              next unless MM::Absorption === component
              value_type = component.object_type
              search_methods = value_type.applicable_parameter_restrictions('Search')
              search_methods.reject!{|vtpr| m = vtpr.value_range.minimum_bound and m.value == 'none'}
              search_methods.map!{|sm| sm.value_range.minimum_bound.value.effective_value}
              if search_methods.empty?
                false
              else
                search_index_by[ix] = search_methods
              end
            end
          return nil if search_index_by.empty?

          search_index_by.flat_map do |search_index, search_methods|
            trace :unidex, "Search #{table_name foreign_key.source_composite} via #{table_name search_index.composite}.#{column_name search_index.all_index_field.to_a[0].component} using #{search_methods.map(&:inspect)*', '}"

            fk_pairs =
                  foreign_key.all_foreign_key_field.to_a.
              zip foreign_key.all_index_field.to_a
            leaf = search_index.all_index_field.to_a[0].component         # Returning this natural index value
            source_table = table_name(foreign_key.composite)
            source_field = safe_column_name(member)
            type_name, options = leaf.data_type(data_type_context)        # Which has this type_name
            intrinsic_type = MM::DataType.intrinsic_type(type_name)       # Which corresponds to this intrinsic type

            col_expr = Expression.new(
              %Q{
                (SELECT  #{safe_column_name(leaf)}
                 FROM    #{source_table} AS f
                 WHERE   #{
                  fk_pairs.map do |fkf, ixf|
                    "#{table_name foreign_key.source_composite}.#{safe_column_name(fkf.component)} = f.#{safe_column_name(ixf.component)}"
                  end*' AND '
                 })}.
              gsub(/\s+/,' '),
              intrinsic_type,
              foreign_key.all_foreign_key_field.to_a.all?{|fkf| fkf.component.path_mandatory}
            )
            search_expr foreign_key.source_composite, intrinsic_type, col_expr, search_methods, source_field
          end
        end

        def generate_value leaf
          return nil unless leaf.is_a?(MM::Absorption)

          value_type = leaf.object_type
          type_name, options = leaf.data_type(data_type_context)
          length = options[:length]
          value_constraint = options[:value_constraint]

          # Look for instructions on how to index this leaf for search:
          search_methods = value_type.applicable_parameter_restrictions('Search')
          search_methods.reject!{|vtpr| m = vtpr.value_range.minimum_bound and m.value == 'none'}
          return nil if search_methods.empty?
          search_methods.map!{|sm| sm.value_range.minimum_bound.value.effective_value}

          # Convert from the model's data type to a metamodel type, if possible
          intrinsic_type = MM::DataType.intrinsic_type(type_name)
          data_type_name = intrinsic_type ? MM::DataType::TypeNames[intrinsic_type] : type_name
          trace :unidex, "Search #{table_name leaf.root}.#{column_name(leaf)} as #{data_type_name} using #{search_methods.map(&:inspect)*', '}"

          col_expr = Expression.new(safe_column_name(leaf), intrinsic_type, leaf.is_mandatory)
          source_field = safe_column_name(leaf)

          search_expr leaf.root, intrinsic_type, col_expr, search_methods, source_field
        end

        def search_expr composite, intrinsic_type, col_expr, search_methods, source_field
          case intrinsic_type
          when MM::DataType::TYPE_Char,
               MM::DataType::TYPE_String,
               MM::DataType::TYPE_Text
            # Produce a select yielding values for the requested search type
            search_methods.flat_map do |sm|
              case sm
              when 'none'         # Do not index this value
                nil

              when 'simple'       # Disregard white-space only
                select(composite, col_expr, 'simple', source_field)

              when 'alpha'        # Strip white space and punctuation, just use alphabetic characters
                select(composite, as_alpha(col_expr), sm, source_field)

              when 'phonetic'     # Use phonetic matching as well as trigrams and alpha
                select(composite, as_alpha(col_expr), 'phonetic', source_field, phonetics(col_expr))

              when 'words'        # Break the text into words and match each word like alpha
                select(composite, unnest(as_words(col_expr)), sm, source_field)

              when 'names'        # Break the text into words and match each word like phonetic
                value = unnest(as_words(col_expr, "''-"))   # N.B. ' is doubled for SQL
                phonetic_select(value, select(composite, value, 'names', source_field))

              when 'text'         # Index a large text field using significant words and phrases
                nil # REVISIT: Implement this type

              when 'number'       # Cast to number and back to text to canonicalise the value;
                # If it doesn't look like a number, we don't index it.
                value = number_or_null(col_expr)
                select(composite, value, 'number', source_field, nil, ["#{value} IS NOT NULL"])

              when 'phone'        # Phone numbers; split, strip each to digits, take the last 8 of each
                select(composite, phone_numbers(col_expr), 'phone', source_field)

              when 'email'        # Use a regexp to find email addresses in this field
                select(composite, email_addresses(col_expr), 'email', source_field)

              when 'date'         # REVISIT: Convert string to standard date format
                # If it doesn't look like a date, we don't index it.
                value = date_or_null(col_expr)
                select(composite, value, 'date', source_field, nil, ["#{value} IS NOT NULL"])

              else
                $stderrs.puts "Unknown search method #{sm}"
              end
            end

          when MM::DataType::TYPE_Boolean
            nil # REVISIT: Implement this type

          when MM::DataType::TYPE_Integer,
               MM::DataType::TYPE_Real,
               MM::DataType::TYPE_Decimal,
               MM::DataType::TYPE_Money
            select(composite, col_expr, 'simple', source_field)

          when MM::DataType::TYPE_Date
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD)
            # REVISIT: Support search methods here
            select(composite, lexical_date(col_expr), 'date', source_field)

          when MM::DataType::TYPE_DateTime,
               MM::DataType::TYPE_Timestamp
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)
            # REVISIT: Support search methods here
            select(composite, lexical_datetime(col_expr), 'datetime', source_field)

          when MM::DataType::TYPE_Time
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)
            select(composite, lexical_time(col_expr), 'time', source_field)

          when MM::DataType::TYPE_Binary
            nil   # No indexing applied
          when nil   # Data Type is unknown
          else
          end
        end

        def stylise_column_name name
          name.words.send(@column_case)*@column_joiner
        end

        def field_names
          @field_names ||=
            %w{Value Phonetic Processing SourceTable SourceField LoadBatchID RecordGUID}.
            map{|n| stylise_column_name(n)}
        end

        def phonetic_select expression, select
          field_list =
            field_names.
            map do |n|
              if n =~ /Phonetic/i
                phonetics(Expression.new(stylise_column_name('Value'), MM::DataType::TYPE_String, true)).to_s + " AS #{n}"
              else
                n
              end
            end.
            join(",\n\t")

          %Q{
            SELECT DISTINCT
                    <FIELDS>
            FROM (<SUB>
            ) AS s}.
          unindent.
          sub(/<FIELDS>/, field_list).
          sub(/<SUB>/, select.gsub(/\n/,"\n\t"))
        end

        def select composite, expression, processing, source_field, phonetic = nil, conditions = []
          # These fields are in order of index precedence, to co-locate
          # comparable values regardless of source record type or column

          select_list =
            [ expression.to_s,
              phonetic ? phonetic.to_s : 'NULL',
              "'"+processing+"'::text",
              "'"+safe_table_name(composite)+"'::text",
              "'"+source_field+"'::text",
              nil,
              nil,
            ].zip(field_names).
            map(&:compact).
            map{|a| a * ' AS '}.
            join(%q{,
                    })
          where =
            if conditions.empty?
              ''
            else
              "\nWHERE\t#{conditions*"\n  AND\t"}"
            end
          select = %Q{
            SELECT DISTINCT
                    #{select_list}
            FROM    #{safe_table_name(composite)}}.
            unindent+
            where

        end

      end
    end
    publish_generator ETL::Unidex, "Generate SQL views to populate a Unified Index, steered by Search parameters on the value types"
  end
end
