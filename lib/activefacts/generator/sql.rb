#
#       ActiveFacts Standard SQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore 
    class SQL
      MM = ActiveFacts::Metamodel
      def self.options
        {
          delay_fks: ['Boolean', "Delay emitting all foreign keys until the bottom of the file"],
          underscore: [String, "Use 'str' instead of underscore between words in table names"],
          unicode: ['Boolean', "Use Unicode for all text fields by default"],
        }
      end

      def initialize composition, options = {}
        @composition = composition
        @options = options
        @delay_fks = options.delete "delay_fks"
        @underscore = options.has_key?("underscore") ? (options['underscore'] || '_') : ''
        @unicode = options.delete "unicode"
      end

      def generate
        @tables_emitted = {}
        @delayed_foreign_keys = []

        generate_schema +
        @composition.
        all_composite.
        sort_by{|composite| composite.mapping.name}.
        map{|composite| generate_table composite}*"\n" + "\n" +
        @delayed_foreign_keys.sort*"\n"
      end

      def data_type_context
        @data_type_context ||= SQLDataTypeContext.new
      end

      def table_name_max
        60
      end

      def column_name_max
        40
      end

      def index_name_max
        60
      end

      def schema_name_max
        60
      end

      def generate_schema
        #go "CREATE SCHEMA #{escape(@composition.name, schema_name_max)}" +
        ''
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
            fk_text = generate_foreign_key fk
            if !@delay_fks and @tables_emitted[fk.composite]
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
        padding = " "*(column_name.size >= column_name_max ? 1 : column_name_max-column_name.size)
        constraints = leaf.all_leaf_constraint

        "-- #{leaf.comment}\n" +
        "\t#{column_name}#{padding}#{column_type leaf, column_name}"
      end

      def auto_assign_type
        ' GENERATED ALWAYS AS IDENTITY'
      end

      def column_type component, column_name
        type_name, options = component.data_type(data_type_context)
        options ||= {}
        length = options[:length]
        value_constraint = options[:value_constraint]
        type_name, length = normalise_type(type_name, length, value_constraint)

        "#{
          type_name
        }#{
          "(#{length}#{(s = options[:scale]) ? ", #{s}" : ''})" if length
        }#{
          ((options[:mandatory] ? ' NOT' : '') + ' NULL') if options.has_key?(:mandatory)
        }#{
          auto_assign_type if a = options[:auto_assign] && a != 'assert'
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

        primary = index.composite_as_primary_index && !contains_nullable_columns
        column_names =
            index.all_index_field.map do |ixf|
              column_name(ixf.component)
            end
        clustering =
          (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')

        if contains_nullable_columns
          table_name = safe_table_name(index.composite)
          delayed_indices <<
            'CREATE UNIQUE'+clustering+' INDEX '+
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
          clustering +
          "(#{column_names.map{|n| escape(n, column_name_max)}*', '})"
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

      # Return SQL type and (modified?) length for the passed base type
      def normalise_type(type_name, length, value_constraint)
        type = MM::DataType.normalise(type_name)

        case type
        when MM::DataType::TYPE_Boolean;  data_type_context.boolean_type
        when MM::DataType::TYPE_Integer
          if type_name =~ /^Auto ?Counter$/i
            MM::DataType.normalise_int_length('int', data_type_context.default_surrogate_length, value_constraint, data_type_context)[0]
          else
            MM::DataType.normalise_int_length(type_name, length, value_constraint, data_type_context)[0]
          end
        when MM::DataType::TYPE_Real;
          ["FLOAT", data_type_context.default_length(type, type_name)]
        when MM::DataType::TYPE_Decimal;  'DECIMAL'
        when MM::DataType::TYPE_Money;    'DECIMAL'
        when MM::DataType::TYPE_Char;     [data_type_context.default_char_type, length || data_type_context.char_default_length]
        when MM::DataType::TYPE_String;   [data_type_context.default_varchar_type, length || data_type_context.varchar_default_length]
        when MM::DataType::TYPE_Text;     [data_type_context.default_text_type, length || 'MAX']
        when MM::DataType::TYPE_Date;     'DATE' # SQLSVR 2K5: 'date'
        when MM::DataType::TYPE_Time;     'TIME' # SQLSVR 2K5: 'time'
        when MM::DataType::TYPE_DateTime; 'TIMESTAMP'
        when MM::DataType::TYPE_Timestamp;'TIMESTAMP'
        when MM::DataType::TYPE_Binary;
          length ||= 16 if type_name =~ /^(guid|uuid)$/i
          if length
            ['BINARY', length]
          else
            'VARBINARY'
          end
        else
          type_name
        end
      end

      def reserved_words
        @reserved_words ||= %w{
          ABSOLUTE ACTION ADD AFTER ALL ALLOCATE ALTER AND ANY ARE
          ARRAY AS ASC ASSERTION AT AUTHORIZATION BEFORE BEGIN
          BETWEEN BINARY BIT BLOB BOOLEAN BOTH BREADTH BY CALL
          CASCADE CASCADED CASE CAST CATALOG CHAR CHARACTER CHECK
          CLOB CLOSE COLLATE COLLATION COLUMN COMMIT CONDITION
          CONNECT CONNECTION CONSTRAINT CONSTRAINTS CONSTRUCTOR
          CONTINUE CORRESPONDING CREATE CROSS CUBE CURRENT CURRENT_DATE
          CURRENT_DEFAULT_TRANSFORM_GROUP CURRENT_TRANSFORM_GROUP_FOR_TYPE
          CURRENT_PATH CURRENT_ROLE CURRENT_TIME CURRENT_TIMESTAMP
          CURRENT_USER CURSOR CYCLE DATA DATE DAY DEALLOCATE DEC
          DECIMAL DECLARE DEFAULT DEFERRABLE DEFERRED DELETE DEPTH
          DEREF DESC DESCRIBE DESCRIPTOR DETERMINISTIC DIAGNOSTICS
          DISCONNECT DISTINCT DO DOMAIN DOUBLE DROP DYNAMIC EACH
          ELSE ELSEIF END EQUALS ESCAPE EXCEPT EXCEPTION EXEC EXECUTE
          EXISTS EXIT EXTERNAL FALSE FETCH FIRST FLOAT FOR FOREIGN
          FOUND FROM FREE FULL FUNCTION GENERAL GET GLOBAL GO GOTO
          GRANT GROUP GROUPING HANDLE HAVING HOLD HOUR IDENTITY IF
          IMMEDIATE IN INDICATOR INITIALLY INNER INOUT INPUT INSERT
          INT INTEGER INTERSECT INTERVAL INTO IS ISOLATION JOIN KEY
          LANGUAGE LARGE LAST LATERAL LEADING LEAVE LEFT LEVEL LIKE
          LOCAL LOCALTIME LOCALTIMESTAMP LOCATOR LOOP MAP MATCH
          METHOD MINUTE MODIFIES MODULE MONTH NAMES NATIONAL NATURAL
          NCHAR NCLOB NESTING NEW NEXT NO NONE NOT NULL NUMERIC
          OBJECT OF OLD ON ONLY OPEN OPTION OR ORDER ORDINALITY OUT
          OUTER OUTPUT OVERLAPS PAD PARAMETER PARTIAL PATH PRECISION
          PREPARE PRESERVE PRIMARY PRIOR PRIVILEGES PROCEDURE PUBLIC
          READ READS REAL RECURSIVE REDO REF REFERENCES REFERENCING
          RELATIVE RELEASE REPEAT RESIGNAL RESTRICT RESULT RETURN
          RETURNS REVOKE RIGHT ROLE ROLLBACK ROLLUP ROUTINE ROW
          ROWS SAVEPOINT SCHEMA SCROLL SEARCH SECOND SECTION SELECT
          SESSION SESSION_USER SET SETS SIGNAL SIMILAR SIZE SMALLINT
          SOME SPACE SPECIFIC SPECIFICTYPE SQL SQLEXCEPTION SQLSTATE
          SQLWARNING START STATE STATIC SYSTEM_USER TABLE TEMPORARY
          THEN TIME TIMESTAMP TIMEZONE_HOUR TIMEZONE_MINUTE TO
          TRAILING TRANSACTION TRANSLATION TREAT TRIGGER TRUE UNDER
          UNDO UNION UNIQUE UNKNOWN UNNEST UNTIL UPDATE USAGE USER
          USING VALUE VALUES VARCHAR VARYING VIEW WHEN WHENEVER
          WHERE WHILE WITH WITHOUT WORK WRITE YEAR ZONE
        }
      end

      def is_reserved_word w
        @reserved_word_hash ||=
          reserved_words.inject({}) do |h,w|
            h[w] = true
            h
          end
        @reserved_word_hash[w.upcase]
      end

      def go s = ''
        "#{s};\n\n"
      end

      def escape s, max = table_name_max
        # Escape SQL keywords and non-identifiers
        if s.size > max
          excess = s[max..-1]
          s = s[0...max-(excess.size/8)] +
            Digest::SHA1.hexdigest(excess)[0...excess.size/8]
        end

        if s =~ /[^A-Za-z0-9_]/ || is_reserved_word(s)
          "[#{s}]"
        else
          s
        end
      end

      def sql_value(value)
        value.is_literal_string ? sql_string(value.literal) : value.literal
      end

      def sql_string(str)
        "'" + str.gsub(/'/,"''") + "'"
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

      class SQLDataTypeContext < MM::DataType::Context
        def integer_ranges
          [
            ['SMALLINT', -2**15, 2**15-1],  # The standard says -10^5..10^5 (less than 16 bits)
            ['INTEGER', -2**31, 2**31-1],   # The standard says -10^10..10^10 (more than 32 bits!)
            ['BIGINT', -2**63, 2**63-1],    # The standard says -10^19..10^19 (less than 64 bits)
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

        def boolean_type
          'BOOLEAN'
        end

        def surrogate_type
          type_name, = choose_integer_type(0, 2**(default_surrogate_length-1)-1)
          type_name
        end

        def valid_from_type
          'TIMESTAMP'
        end

        def date_time_type
          'TIMESTAMP'
        end

        def default_char_type
          (@unicode ? 'NATIONAL ' : '') +
          'CHARACTER'
        end

        def default_varchar_type
          (@unicode ? 'NATIONAL ' : '') +
          'VARCHAR'
        end

        def char_default_length
          nil
        end

        def varchar_default_length
          nil
        end

        def default_surrogate_length
          64
        end

        def default_text_type
          default_varchar_type
        end
      end

      def safe_table_name composite
        escape(table_name(composite), table_name_max)
      end

      def safe_column_name component
        escape(column_name(component), column_name_max)
      end

      def table_name composite
        composite.mapping.name.gsub(' ', @underscore)
      end

      def column_name component
        component.column_name.capcase
      end

    end
    publish_generator SQL
  end
end
