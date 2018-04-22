#
#       ActiveFacts BIML Traits
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
# Copyright (c) 2018 Factil Pty Ltd.
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
require 'activefacts/generator/traits/expr'

module ActiveFacts
  module Generators
    module Traits
      module BIML
        MM = ActiveFacts::Metamodel unless const_defined?(:MM)

        # Options available in BIML
        def options
          {
            keywords: ['Boolean', "Quote all keywords, not just reserved words"],
            restrict: ['String', "Restrict generation to tables in the specified group (e.g. bdv, rdv)"],
            joiner: ['String', "Use 'str' instead of the default joiner between words in table and column names"],
            unicode: ['Boolean', "Use Unicode for all text fields by default"],
            tables: [%w{cap title camel snake shout}, "Case to use for table names"],
            columns: [%w{cap title camel snake shout}, "Case to use for table names"],
            surrogates: [%w{counter guid hash}, "Method to use for assigning surrogate keys"],
            fks: [%w{no yes delay}, "Emit foreign keys, delay them to the end, or omit them"],
          }
        end

        # The options parameter overrides any default options set by sub-traits
        def defaults_and_options options
          options
        end

        def process_options options
          @options = defaults_and_options options

          @quote_keywords = {nil=>true, 't'=>true, 'f'=>false, 'y'=>true, 'n'=>false}[@options.delete 'keywords']
          @quote_keywords = false if @keywords == nil  # Set default
          case (@options.delete "fks" || true)
          when true, '', 't', 'y', 'yes'
            @fks = true
          when 'd', 'delay'
            @fks = true
            @delay_fks = true
          when false, 'f', 'n', 'no'
            @fks = false
          end
          @unicode = @options.delete "unicode"
          @restrict = @options.delete "restrict"
          @surrogate_method = @options.delete('surrogates') || 'counter'
          raise "Unknown surrogate assignment method" unless %w{counter guid hash}.include?(@surrogate_method)

          # Name configuration options:
          @joiner = @options.delete('joiner')
          @table_joiner = @options.has_key?('tables') ? @joiner : nil
          @table_case = ((@options.delete('tables') || 'cap') + 'words').to_sym
          @table_joiner ||= [:snakewords, :shoutwords].include?(@table_case) ? '_' : ''
          @column_joiner = @options.has_key?('columns') ? @joiner : nil
          @column_case = ((@options.delete('columns') || 'cap') + 'words').to_sym
          @column_joiner ||= [:snakewords, :shoutwords].include?(@column_case) ? '_' : ''

          # Do not (yet) expose the closed-world vs open world problem.
          # Closed World vs Open World uniqueness is a semantic issue,
          # and so is OW, CW or CW with negation for unary fact types.
          # We need an overall strategy for handling it.
          @closed_world_indices = false   # Allow for SQL Server's non-standard NULL indexing
        end

        def data_type_context
          @data_type_context ||= data_type_context_class.new(surrogate_method: @surrogate_method)
        end

        def data_type_context_class
          BIMLDataTypeContext
        end

        def table_name_max
          1024
        end

        def column_name_max
          1024
        end

        def index_name_max
          1024
        end

        def schema_name_max
          1024
        end

        # Anything this flavour needs to prefix a schema:
        def schema_prefix
          ''
        end

        def index_kind(index)
          ''
        end

        def binary_surrogate(type_name, value_constraint, options)
          if options[:auto_assign] == 'hash'
            :hash
          elsif type_name =~ /^(guid|uuid)$/i
            options[:length] ||= 16
            if ![nil, ''].include?(options[:auto_assign])
              options.delete(:auto_assign)  # Don't auto-assign foreign keys
              :guid
            else
              :guid_fk
            end
          else
            false
          end
        end

        # Return SQL type and (modified?) length for the passed base type
        def choose_sql_type(type_name, value_constraint, component, options)
          case MM::DataType.intrinsic_type(type_name)
          when MM::DataType::TYPE_Boolean
            data_type_context.boolean_type

          when MM::DataType::TYPE_Integer
            # The :auto_assign key is set for auto-assigned types, but with a nil value in foreign keys
            length = options[:length]
            if options.has_key?(:auto_assign)
              options[:default] ||= ' GENERATED ALWAYS AS IDENTITY' if options[:auto_assign]
              length = data_type_context.default_autoincrement_length
              type_name = 'int'
            end
            if chosen = MM::DataType.choose_integer(type_name, length, value_constraint, data_type_context)
              options.delete(:length)
              chosen
            else  # No available integer seems to suit. Use the defined type and length
              type_name
            end

          when MM::DataType::TYPE_Real
            'Double'

          when MM::DataType::TYPE_Decimal
            'Decimal'

          when MM::DataType::TYPE_Money
            'Currency'

          when MM::DataType::TYPE_Char
            data_type_context.default_char_type

          when MM::DataType::TYPE_String
            data_type_context.default_varchar_type

          when MM::DataType::TYPE_Text
            options[:length] ||= 'MAX'
            data_type_context.default_text_type

          when MM::DataType::TYPE_Date
            'Date'

          when MM::DataType::TYPE_Time
            'Time'

          when MM::DataType::TYPE_DateTime
            'DateTime'

          when MM::DataType::TYPE_Timestamp
            'Binary'

          when MM::DataType::TYPE_Binary
            # If it's a surrogate, that might change the length we use
            binary_surrogate(type_name, value_constraint, options)
            if options[:length]
              'Binary'          # Fixed length
            else
              'Binary'
            end
          else
            type_name
          end
        end

        # The Components passed as leaves are fields in a table.
        # Return an array of SQL field names.
        def safe_column_names leaves
          leaves.map &method(:safe_column_name)
        end

        # Return an Expression for the Component passed as leaf, optionally using a table or alias name
        def safe_column_expr leaf, table_prefix = ''
          column_name = safe_column_name(leaf)
          type_name, = leaf.data_type(data_type_context)
          type_num = MM::DataType.intrinsic_type(type_name)
          Expression.new(table_prefix+column_name, type_num, leaf.is_mandatory)
        end

        # Return an array of Expressions for the fields, optionally qualified with a table or alias name
        def safe_column_exprs leaves, use_table_name = nil
          leaves.map{|leaf| safe_column_expr(leaf, table_prefix(leaf, use_table_name))}
        end

        # Return the string to prefix a column expression with to qualify it with a table or alias name
        def table_prefix component, use_table_name = nil
          case use_table_name
          when false, nil
            ''
          when true
            safe_table_name(component)+'.'
          else
            use_table_name+'.'
          end
        end

        def create_or_replace(name, kind)
          # There's no standard BIML way to do this. Do it anyway.
          ''
        end

        # For an (array of) Expression, return expressions that have value "na" if NULL
        def coalesce exprs, na = "'NA'"
          return exprs.map{|expr| coalesce(expr)} if Array === exprs
          return exprs if exprs.is_mandatory
          Expression.new("COALESCE(#{exprs}, #{na})", exprs.type_num, true)
        end

        def reserved_words
          @reserved_words ||= %w{
          }
        end

        def key_words
          @key_words ||= %w{
          }
        end

        def is_reserved_word w
          @reserved_word_hash ||=
            ( reserved_words +
              (@quote_keywords ? key_words : [])).
            inject({}) do |h,w|
              h[w] = true
              h
            end
          @reserved_word_hash[w.upcase]
        end

        def go s = ''
          ''
        end

        def sql_value(value)
          value.is_literal_string ? sql_string(value.literal) : value.literal
        end

        def sql_string(str)
          "'" + str.gsub(/'/,"''") + "'"
        end

        def open_escape
          '"'
        end

        def close_escape
          '"'
        end

        def escape s, max = table_name_max
          # Escape SQL keywords and non-identifiers
          if s.size > max
            excess = s[max..-1]
            s = s[0...max-(excess.size/8)] +
              Digest::SHA1.hexdigest(excess)[0...excess.size/8]
          end

          if s =~ /[^A-Za-z0-9_]/ || is_reserved_word(s)
            "#{open_escape}#{s}#{close_escape}"
          else
            s
          end
        end

        def safe_table_name composite
          escape(table_name(composite), table_name_max)
        end

        def safe_column_name component
          escape(column_name(component), column_name_max)
        end

        def schema_name composition = @composition
          composition.name.words.send(@table_case)*@table_joiner
        end

        def table_name composite
          composite.mapping.name.words.send(@table_case)*@table_joiner
        end

        def column_name component
          words = component.column_name.send(@column_case)
          words*@column_joiner
        end

        def check_clause column_name, value_constraint
          " CHECK(" +
            value_constraint.all_allowed_range_sorted.map do |ar|
              vr = ar.value_range
              min = vr.minimum_bound
              max = vr.maximum_bound
              if (min && max && max.value.literal == min.value.literal)
                "#{column_name} = #{sql_value(min.value)}"
              else
                inequalities = [
                  min && "#{column_name} >#{min.is_inclusive ? "=" : ""} #{sql_value(min.value)}",
                  max && "#{column_name} <#{max.is_inclusive ? "=" : ""} #{sql_value(max.value)}"
                ].compact
                inequalities.size > 1 ? "(" + inequalities*" AND " + ")" : inequalities[0]
              end
            end*" OR " +
          ")"
        end

        class BIMLDataTypeContext < MM::DataType::Context
          def initialize options = {}
            @surrogate_method = options.delete(:surrogate_method) || "counter"
            super
          end

          def integer_ranges
            [
              ['Int16', -2**15, 2**15-1],  # The standard says -10^5..10^5 (less than 16 bits)
              ['Int32', -2**31, 2**31-1],   # The standard says -10^10..10^10 (more than 32 bits!)
              ['Int64', -2**63, 2**63-1],    # The standard says -10^19..10^19 (less than 64 bits)
            ]
          end

          def default_length data_type, type_name
            case data_type
            when MM::DataType::TYPE_Real
              53        # IEEE Double precision floating point
            when MM::DataType::TYPE_Integer
              case type_name
              when /([a-z ]|\b)Tiny([a-z ]|\b)/i
                8
              when /([a-z ]|\b)Small([a-z ]|\b)/i,
                /([a-z ]|\b)Short([a-z ]|\b)/i
                16
              when /([a-z ]|\b)Big(INT)?([a-z ]|\b)/i
                64
              else
                32
              end
            else
              nil
            end
          end

          # Note that BOOLEAN is an optional data type in SQL99.
          # Official literals are TRUE, FALSE and UNKNOWN.
          # Almost nothing (except Postgres) implements BOOLEAN, and
          # even that doesn't implement UNKNOWN (which works like NULL)
          def boolean_type
            'Boolean'
          end

          # safe_column_name is an expression which yields boolean_type.
          # We use boolean_expr when we want to use it in a conditional context.
          def boolean_expr safe_column_name
            safe_column_name
          end

          def hash_type
            ['Binary', {length: 32, auto_assign: 'hash' }]
          end

          # What type to use for a Metamodel::SurrogateKey
          def surrogate_type
            case @surrogate_method
            when 'guid'
              ["Guid", {auto_assign: 'guid'}]
            when 'hash'
              hash_type
            else  # counter
              type_name, min, max, length = choose_integer_range(0, 2**(default_autoincrement_length-1)-1)
              type_name
            end
          end

          def date_time_type
            'DateTime'
          end

          def default_char_type
            (@unicode ? '' : 'Ansi') +
            'StringFixedLength'
          end

          def default_varchar_type
            (@unicode ? '' : 'Ansi') +
            'String'
          end

          # Number of bits in an auto-counter
          def default_autoincrement_length
            64
          end

          def default_text_type
            default_varchar_type
          end
        end

      end
    end
  end
end
