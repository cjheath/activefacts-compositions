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
        include Traits::SQL 
        extend Traits::SQL

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
        def self.options
          # REVISIT: There's no way to support SQL dialect options here
          super.merge(
            {
              dialect: ['String', "SQL Dialect to use"],
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
            self.class.include @trait
            self.class.extend @trait
            extend @trait
          end
          process_options options
        end

        def generate
          header +
          @composition.all_composite.map{|c| generate_composite c}.compact*"\n"+
          trailer
        end

        def header
          ''
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
                  generate_joined_value member.foreign_key
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
              "CREATE VIEW #{table_name(composite)}_unidex ON" +
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
          # select leaf.root, safe_column_name(leaf), 1, 1
        end
        
        # This foreign key connects two composites (tables)
        def generate_joined_value foreign_key
          return nil unless foreign_key.composite.mapping.object_type.is_static

          # Index the source table by the natural key of the target, if we can find one
          indices = foreign_key.composite.all_index
          return null if indices.empty?

          search_index_by = {}
          searchable_indices =
            indices.select do |ix|
              next false if !ix.is_unique || ix.all_index_field.size > 1
              component = ix.all_index_field.single.component
              next unless MM::Absorption === component &&
                (value_type = component.object_type) &&
                MM::ValueType === value_type
              search_methods = value_type.applicable_parameter_restrictions('Search')
              search_methods.reject!{|vtpr| m = vtpr.value_range.minimum_bound and m.value == 'none'}
              if search_methods.empty?
                false
              else
                search_index_by[ix] = search_methods
              end
            end
          return nil if search_index_by.empty?
          search_index_by.map do |si, settings|
            trace :unidex, "Search #{table_name foreign_key.source_composite} via #{table_name si.composite}.#{column_name si.all_index_field.single.component} using #{settings.map(&:inspect)*', '}"

            # REVISIT: Generate search join expression

            nil
          end
        end

        def generate_value leaf
          return nil unless leaf.is_a?(MM::Absorption)

          value_type = leaf.object_type
          type_name, options = leaf.data_type(MM::DataType::DefaultContext)
          length = options[:length]
          value_constraint = options[:value_constraint]

          # Look for instructions on how to index this leaf for search:
          search_methods = value_type.applicable_parameter_restrictions('Search')
          search_methods.reject!{|vtpr| m = vtpr.value_range.minimum_bound and m.value == 'none'}
          return nil if search_methods.empty?

          # Convert from the model's data type to a metamodel type, if possible
          intrinsic_type = MM::DataType.intrinsic_type(type_name)
          data_type_name = intrinsic_type ? MM::DataType::TypeNames[intrinsic_type] : type_name
          trace :unidex, "Search #{table_name leaf.root}.#{column_name(leaf)} as #{data_type_name} using #{search_methods.map(&:inspect)*', '}"

return nil

          case intrinsic_type
          when MM::DataType::TYPE_Char,
               MM::DataType::TYPE_String,
               MM::DataType::TYPE_Text
            # Produce a truncated value with the requested search

          when MM::DataType::TYPE_Boolean,
               MM::DataType::TYPE_Integer,
               MM::DataType::TYPE_Real,
               MM::DataType::TYPE_Decimal,
               MM::DataType::TYPE_Money
            # Produce a right-justified value

          when MM::DataType::TYPE_Date
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD)

          when MM::DataType::TYPE_DateTime,
               MM::DataType::TYPE_Timestamp
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)

          when MM::DataType::TYPE_Time
            # Produce an ISO representation that sorts lexically (YYYY-MM-DD HH:mm:ss)

          when MM::DataType::TYPE_Binary
            # No indexing applied
          when nil   # Data Type is unknown
          else
          end

          # REVISIT: Use the data type parameters, when they're implemented
          [
            # REVISIT: First key should be lexically cleansed and down-cased
            select(leaf.root, safe_column_name(leaf), 1, 1),
            select(leaf.root, 'dmetaphone('+safe_column_name(leaf)+')', 1, 0.7),
            select(leaf.root, 'dmetaphone_alt('+safe_column_name(leaf)+')', 1, 0.7),

            # REVISIT: Strings should be indexed by exact words
            # REVISIT: Strings should be indexed by metaphone and metaphone_alt
            # REVISIT: Strings should be indexed by trigram
            # REVISIT: Dates should be indexed by round-down(5 years) and round-up(5 years)
            # REVISIT: Numbers could be indexed by round-down(some range) and round-up(some range)
          ].compact
        end

        def select composite, expression, processing_level, confidence = 1
          %Q{
          SELECT  #{processing_level} AS ProcLevel,
                  #{expression} AS Value,
                  LoadBatchID,
                  #{confidence} AS Confidence,
                  RecordUUID,
                  '#{expression}' AS Column
          FROM    #{table_name(composite)}}.
          unindent
        end

      end
    end
    publish_generator ETL::Unidex
  end
end
