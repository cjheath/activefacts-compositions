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
              dialect: [String, "SQL Dialect to use"],
              value_width: [Integer, "Number of characters to index from long values"],
              phonetic_confidence: [Integer, "Percentage confidence for a phonetic match"],
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
          @value_width = (options.delete('value_width') || 32).to_i
          @phonetic_confidence = (options.delete('phonetic_confidence') || 70).to_i

          super
        end

        def generate
          header +
          @composition.
            all_composite.
            sort_by{|c| c.mapping.object_type.name}.
            map{|c| generate_composite c}.
            compact*"\n" +
          trailer
        end

        def header
          schema_prefix
        end

        def generate_composite composite
          return nil if composite.mapping.injection_annotation
          return nil if composite.mapping.object_type.is_static

          trace :unidex, "Generating view for #{table_name(composite)}" do
            union =
            composite.mapping.all_member.to_a.flat_map do |member|
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
            end.compact * "\nUNION"

            if union.size > 0
              "/*\n"+
              " * View to extract unified index values for #{table_name(composite)}\n"+
              " */\n"+
              "CREATE VIEW #{table_name(composite)}_unidex AS" +
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
          # select leaf.root, safe_column_name(leaf), 1, column_name(leaf), 1
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
            source = (member.column_name+leaf.column_name).elide_repeated_subsequences*' '
            type_name, options = leaf.data_type(data_type_context)        # Which has this type_name
            intrinsic_type = MM::DataType.intrinsic_type(type_name)       # Which corresponds to this intrinsic type

            col_expr = Expression.new(
              %Q{
                (SELECT  #{safe_column_name(leaf)}
                 FROM    #{source} AS f
                 WHERE   #{
                  fk_pairs.map do |fkf, ixf|
                    "#{table_name foreign_key.source_composite}.#{safe_column_name(fkf.component)} = f.#{safe_column_name(ixf.component)}"
                  end*' AND '
                 })}.
              gsub(/\s+/,' '),
              intrinsic_type,
              foreign_key.all_foreign_key_field.to_a.all?{|fkf| fkf.component.path_mandatory}
            )
            search_expr foreign_key.source_composite, intrinsic_type, col_expr, search_methods, source
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
          source = leaf.column_name*' '

          search_expr leaf.root, intrinsic_type, col_expr, search_methods, source
        end

        def search_expr composite, intrinsic_type, col_expr, search_methods, source
          case intrinsic_type
          when MM::DataType::TYPE_Char,
               MM::DataType::TYPE_String,
               MM::DataType::TYPE_Text
            # Produce a truncated value with the requested search
            search_methods.flat_map do |sm|
              case sm
              when 'none'         # Do not index this value
                nil
              when 'simple'       # Disregard white-space only
                select(composite, truncate(col_expr, @value_width), 'simple', source, 1.0)

              when 'alpha'        # Strip white space and punctuation, just use alphabetic characters
                select(composite, truncate(as_alpha(col_expr), @value_width), 'alpha', source, 0.9)

              when 'words'        # Break the text into words and match each word like alpha
                nil # REVISIT: Implement this type

              # when 'phrases'    # Words, but where adjacent sequences of words matter
              when 'typo'         # Use trigram similarity to detect typographic errors
                # REVISIT: Implement this type properly
                select(composite, truncate(as_alpha(col_expr), @value_width), 'typo', source, 0.9)

              when 'phonetic'     # Use phonetic matching as well as trigrams
                phonetics(col_expr).map do |p|
                  select(composite, p, 'phonetic', source, @phonetic_confidence/100.0)
                end

              when 'names'        # Break the text into words and match each word like phonetic
                nil # REVISIT: Implement this type

              when 'text'         # Index a large text field using significant words and phrases
                nil # REVISIT: Implement this type
              else
                raise "Unknown search method #{sm}"
              end
            end

          when MM::DataType::TYPE_Boolean
            nil # REVISIT: Implement this type

          when MM::DataType::TYPE_Integer,
               MM::DataType::TYPE_Real,
               MM::DataType::TYPE_Decimal,
               MM::DataType::TYPE_Money
            # Produce a right-justified value
            select(composite, lexical_decimal(col_expr, @value_width, value_type.scale), 'simple', source, 1)

          when MM::DataType::TYPE_Date
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD)
            # REVISIT: Support search methods here
            select(composite, lexical_date(col_expr), 'simple', source, 1)

          when MM::DataType::TYPE_DateTime,
               MM::DataType::TYPE_Timestamp
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)
            # REVISIT: Support search methods here
            select(composite, lexical_datetime(col_expr), 'simple', source, 1)

          when MM::DataType::TYPE_Time
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)
            select(composite, lexical_time(col_expr), 'simple', source, 1)

          when MM::DataType::TYPE_Binary
            nil   # No indexing applied
          when nil   # Data Type is unknown
          else
          end
        end

        def stylise_column_name name
          name.words.send(@column_case)*@column_joiner
        end

        def select composite, expression, processing, source, confidence = 1, where = []
          # These fields are in order of index precedence, to co-locate
          # comparable values regardless of source record type or column
          where << 'Value IS NOT NULL' if expression.to_s =~ /\bNULL\b/
          processing_name = stylise_column_name("Processing")
          value_name = stylise_column_name("Value")
          load_batch_id_name = stylise_column_name("LoadBatchID")
          record_guid_name = stylise_column_name("RecordGUID")
          confidence_name = stylise_column_name("Confidence")
          source_name = stylise_column_name("Source")
          select = %Q{
            SELECT  '#{processing}' AS #{processing_name},
                    #{expression} AS #{value_name},
                    #{load_batch_id_name},
                    #{"%.2f" % confidence} AS #{confidence_name},
                    #{record_guid_name},
                    '#{source}' AS #{source_name}
            FROM    #{table_name(composite)}}.
            unindent

          if where.empty?
            select
          else
            "\nSELECT * FROM (#{select}\n) AS s WHERE #{where*' AND '}"
          end

        end

      end
    end
    publish_generator ETL::Unidex
  end
end
