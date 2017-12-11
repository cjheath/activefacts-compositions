#
#       ActiveFacts Standard SQL Traits
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
require 'activefacts/generator/traits/expr'

module ActiveFacts
  module Generators
    module Traits
      module SQL
        MM = ActiveFacts::Metamodel unless const_defined?(:MM)

        # Options available in this flavour of SQL
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
            # Legacy: datavault: ['String', "Generate 'raw' or 'business' data vault tables"],
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

          # Legacy option. Use restrict=bdv/rdv instead
          @datavault = @options.delete "datavault"
          case @datavault
          when "business"
            @restrict = "bdv"
          when "raw"
            @restrict = "rdv"
          end

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
          SQLDataTypeContext
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
            'FLOAT'

          when MM::DataType::TYPE_Decimal
            'DECIMAL'

          when MM::DataType::TYPE_Money
            'DECIMAL'

          when MM::DataType::TYPE_Char
            data_type_context.default_char_type

          when MM::DataType::TYPE_String
            data_type_context.default_varchar_type

          when MM::DataType::TYPE_Text
            options[:length] ||= 'MAX'
            data_type_context.default_text_type

          when MM::DataType::TYPE_Date
            'DATE'

          when MM::DataType::TYPE_Time
            'TIME'

          when MM::DataType::TYPE_DateTime
            'TIMESTAMP'

          when MM::DataType::TYPE_Timestamp
            'TIMESTAMP'

          when MM::DataType::TYPE_Binary
            # If it's a surrogate, that might change the length we use
            binary_surrogate(type_name, value_constraint, options)
            if options[:length]
              'BINARY'          # Fixed length
            else
              'VARBINARY'
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
          # There's no standard SQL way to do this. Do it anyway.
          "CREATE OR REPLACE #{kind} #{name}"
        end

        # For an (array of) Expression, return expressions that have value "na" if NULL
        def coalesce exprs, na = "'NA'"
          return exprs.map{|expr| coalesce(expr)} if Array === exprs
          return exprs if exprs.is_mandatory
          Expression.new("COALESCE(#{exprs}, #{na})", exprs.type_num, true)
        end

        def reserved_words
          @reserved_words ||= %w{
            ABS ABSOLUTE ACTION ADD ALL ALLOCATE ALTER AND ANY ARE
            ARRAY ARRAY_AGG ARRAY_MAX_CARDINALITY AS ASC ASENSITIVE
            ASSERTION ASYMMETRIC AT ATOMIC AUTHORIZATION AVG BEGIN
            BEGIN_FRAME BEGIN_PARTITION BETWEEN BIGINT BINARY BIT
            BIT_LENGTH BLOB BOOLEAN BOTH BY CALL CALLED CARDINALITY
            CASCADE CASCADED CASE CAST CATALOG CEIL CEILING CHAR
            CHARACTER CHARACTER_LENGTH CHAR_LENGTH CHECK CLOB CLOSE
            COALESCE COLLATE COLLATION COLLECT COLUMN COMMIT CONDITION
            CONNECT CONNECTION CONSTRAINT CONSTRAINTS CONTAINS CONTINUE
            CONVERT CORR CORRESPONDING COUNT COVAR_POP COVAR_SAMP
            CREATE CROSS CUBE CUME_DIST CURRENT CURRENT_CATALOG
            CURRENT_DATE CURRENT_DEFAULT_TRANSFORM_GROUP CURRENT_PATH
            CURRENT_ROLE CURRENT_ROW CURRENT_SCHEMA CURRENT_TIME
            CURRENT_TIMESTAMP CURRENT_TRANSFORM_GROUP_FOR_TYPE
            CURRENT_USER CURSOR CYCLE DATALINK DATE DAY DEALLOCATE
            DEC DECIMAL DECLARE DEFAULT DEFERRABLE DEFERRED DELETE
            DENSE_RANK DEREF DESC DESCRIBE DESCRIPTOR DETERMINISTIC
            DIAGNOSTICS DISCONNECT DISTINCT DLNEWCOPY DLPREVIOUSCOPY
            DLURLCOMPLETE DLURLCOMPLETEONLY DLURLCOMPLETEWRITE DLURLPATH
            DLURLPATHONLY DLURLPATHWRITE DLURLSCHEME DLURLSERVER
            DLVALUE DO DOMAIN DOUBLE DROP DYNAMIC EACH ELEMENT ELSE
            ELSEIF END END-EXEC END_FRAME END_PARTITION EQUALS ESCAPE
            EVERY EXCEPT EXCEPTION EXEC EXECUTE EXISTS EXIT EXP
            EXTERNAL EXTRACT FALSE FETCH FILTER FIRST FIRST_VALUE
            FLOAT FLOOR FOR FOREIGN FOUND FRAME_ROW FREE FROM FULL
            FUNCTION FUSION GET GLOBAL GO GOTO GRANT GROUP GROUPING
            GROUPS HANDLER HAVING HOLD HOUR IDENTITY IF IMMEDIATE
            IMPORT IN INDICATOR INITIALLY INNER INOUT INPUT INSENSITIVE
            INSERT INT INTEGER INTERSECT INTERSECTION INTERVAL INTO
            IS ISOLATION ITERATE JOIN KEY LAG LANGUAGE LARGE LAST
            LAST_VALUE LATERAL LEAD LEADING LEAVE LEFT LEVEL LIKE
            LIKE_REGEX LN LOCAL LOCALTIME LOCALTIMESTAMP LOOP LOWER
            MATCH MAX MAX_CARDINALITY MEMBER MERGE METHOD MIN MINUTE
            MOD MODIFIES MODULE MONTH MULTISET NAMES NATIONAL NATURAL
            NCHAR NCLOB NEW NEXT NO NONE NORMALIZE NOT NTH_VALUE NTILE
            NULL NULLIF NUMERIC OCCURRENCES_REGEX OCTET_LENGTH OF
            OFFSET OLD ON ONLY OPEN OPTION OR ORDER OUT OUTER OUTPUT
            OVER OVERLAPS OVERLAY PAD PARAMETER PARTIAL PARTITION
            PERCENT PERCENTILE_CONT PERCENTILE_DISC PERCENT_RANK
            PERIOD PORTION POSITION POSITION_REGEX POWER PRECEDES
            PRECISION PREPARE PRESERVE PRIMARY PRIOR PRIVILEGES
            PROCEDURE PUBLIC RANGE RANK READ READS REAL RECURSIVE REF
            REFERENCES REFERENCING REGR_AVGX REGR_AVGY REGR_COUNT
            REGR_INTERCEPT REGR_R2 REGR_SLOPE REGR_SXX REGR_SXY
            REGR_SYY RELATIVE RELEASE REPEAT RESIGNAL RESTRICT RESULT
            RETURN RETURNS REVOKE RIGHT ROLLBACK ROLLUP ROW ROWS
            ROW_NUMBER SAVEPOINT SCHEMA SCOPE SCROLL SEARCH SECOND
            SECTION SELECT SENSITIVE SESSION SESSION_USER SET SIGNAL
            SIMILAR SIZE SMALLINT SOME SPACE SPECIFIC SPECIFICTYPE
            SQL SQLCODE SQLERROR SQLEXCEPTION SQLSTATE SQLWARNING
            SQRT START STATIC STDDEV_POP STDDEV_SAMP SUBMULTISET
            SUBSTRING SUBSTRING_REGEX SUCCEEDS SUM SYMMETRIC SYSTEM
            SYSTEM_TIME SYSTEM_USER TABLE TABLESAMPLE TEMPORARY THEN
            TIME TIMESTAMP TIMEZONE_HOUR TIMEZONE_MINUTE TO TRAILING
            TRANSACTION TRANSLATE TRANSLATE_REGEX TRANSLATION TREAT
            TRIGGER TRIM TRIM_ARRAY TRUE TRUNCATE UESCAPE UNDO UNION
            UNIQUE UNKNOWN UNNEST UNTIL UPDATE UPPER USAGE USER USING
            VALUE VALUES VALUE_OF VARBINARY VARCHAR VARYING VAR_POP
            VAR_SAMP VERSIONING VIEW WHEN WHENEVER WHERE WHILE
            WIDTH_BUCKET WINDOW WITH WITHIN WITHOUT WORK WRITE XML
            XMLAGG XMLATTRIBUTES XMLBINARY XMLCAST XMLCOMMENT XMLCONCAT
            XMLDOCUMENT XMLELEMENT XMLEXISTS XMLFOREST XMLITERATE
            XMLNAMESPACES XMLPARSE XMLPI XMLQUERY XMLSERIALIZE XMLTABLE
            XMLTEXT XMLVALIDATE YEAR ZONE
          }
        end

        def key_words
          @key_words ||= %w{
            A ABSENT ACCORDING ADA ADMIN AFTER ALWAYS ASSIGNMENT
            ATTRIBUTE ATTRIBUTES BASE64 BEFORE BERNOULLI BLOCKED BOM
            BREADTH C CATALOG_NAME CHAIN CHARACTERISTICS CHARACTERS
            CHARACTER_SET_CATALOG CHARACTER_SET_NAME CHARACTER_SET_SCHEMA
            CLASS_ORIGIN COBOL COLLATION_CATALOG COLLATION_NAME
            COLLATION_SCHEMA COLUMNS COLUMN_NAME COMMAND_FUNCTION
            COMMAND_FUNCTION_CODE COMMITTED CONDITION_NUMBER
            CONNECTION_NAME CONSTRAINT_CATALOG CONSTRAINT_NAME
            CONSTRAINT_SCHEMA CONSTRUCTOR CONTENT CONTROL CURSOR_NAME
            DATA DATETIME_INTERVAL_CODE DATETIME_INTERVAL_PRECISION
            DB DEFAULTS DEFINED DEFINER DEGREE DEPTH DERIVED DISPATCH
            DOCUMENT DYNAMIC_FUNCTION DYNAMIC_FUNCTION_CODE EMPTY
            ENCODING ENFORCED EXCLUDE EXCLUDING EXPRESSION FILE FINAL
            FLAG FOLLOWING FORTRAN FS G GENERAL GENERATED GRANTED HEX
            HIERARCHY ID IGNORE IMMEDIATELY IMPLEMENTATION INCLUDING
            INCREMENT INDENT INSTANCE INSTANTIABLE INSTEAD INTEGRITY
            INVOKER K KEY_MEMBER KEY_TYPE LENGTH LIBRARY LIMIT LINK
            LOCATION LOCATOR M MAP MAPPING MATCHED MAXVALUE MESSAGE_LENGTH
            MESSAGE_OCTET_LENGTH MESSAGE_TEXT MINVALUE MORE MUMPS
            NAME NAMESPACE NESTING NFC NFD NFKC NFKD NIL NORMALIZED
            NULLABLE NULLS NUMBER OBJECT OCTETS OFF OPTIONS ORDERING
            ORDINALITY OTHERS OVERRIDING P PARAMETER_MODE PARAMETER_NAME
            PARAMETER_ORDINAL_POSITION PARAMETER_SPECIFIC_CATALOG
            PARAMETER_SPECIFIC_NAME PARAMETER_SPECIFIC_SCHEMA PASCAL
            PASSING PASSTHROUGH PATH PERMISSION PLACING PLI PRECEDING
            RECOVERY REPEATABLE REQUIRING RESPECT RESTART RESTORE
            RETURNED_CARDINALITY RETURNED_LENGTH RETURNED_OCTET_LENGTH
            RETURNED_SQLSTATE RETURNING ROLE ROUTINE ROUTINE_CATALOG
            ROUTINE_NAME ROUTINE_SCHEMA ROW_COUNT SCALE SCHEMA_NAME
            SCOPE_CATALOG SCOPE_NAME SCOPE_SCHEMA SECURITY SELECTIVE
            SELF SEQUENCE SERIALIZABLE SERVER SERVER_NAME SETS SIMPLE
            SOURCE SPECIFIC_NAME STANDALONE STATE STATEMENT STRIP
            STRUCTURE STYLE SUBCLASS_ORIGIN T TABLE_NAME TIES TOKEN
            TOP_LEVEL_COUNT TRANSACTIONS_COMMITTED TRANSACTIONS_ROLLED_BACK
            TRANSACTION_ACTIVE TRANSFORM TRANSFORMS TRIGGER_CATALOG
            TRIGGER_NAME TRIGGER_SCHEMA TYPE UNBOUNDED UNCOMMITTED
            UNDER UNLINK UNNAMED UNTYPED URI USER_DEFINED_TYPE_CATALOG
            USER_DEFINED_TYPE_CODE USER_DEFINED_TYPE_NAME
            USER_DEFINED_TYPE_SCHEMA VALID VERSION WHITESPACE WRAPPER
            XMLDECLARATION XMLSCHEMA YES
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
          "#{s.sub(/\A\n+/,'')};\n"
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

        class SQLDataTypeContext < MM::DataType::Context
          def initialize options = {}
            @surrogate_method = options.delete(:surrogate_method) || "counter"
            super
          end

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

          # Note that BOOLEAN is an optional data type in SQL99.
          # Official literals are TRUE, FALSE and UNKNOWN.
          # Almost nothing (except Postgres) implements BOOLEAN, and
          # even that doesn't implement UNKNOWN (which works like NULL)
          def boolean_type
            'BOOLEAN'
          end

          # safe_column_name is an expression which yields boolean_type.
          # We use boolean_expr when we want to use it in a conditional context.
          def boolean_expr safe_column_name
            safe_column_name
          end

          def hash_type
            ['BINARY', {length: 32, auto_assign: 'hash' }]
          end

          # What type to use for a Metamodel::SurrogateKey
          def surrogate_type
            case @surrogate_method
            when 'guid'
              ["GUID", {auto_assign: 'guid'}]
            when 'hash'
              hash_type
            else  # counter
              type_name, min, max, length = choose_integer_range(0, 2**(default_autoincrement_length-1)-1)
              type_name
            end
          end

          # What type to use for a Metamodel::ValidFrom
          def valid_from_type
            date_time_type
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
