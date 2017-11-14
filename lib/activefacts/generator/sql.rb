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

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore
    class SQL
      MM = ActiveFacts::Metamodel unless const_defined?(:MM)
      def self.options
        {
          delay_fks: ['Boolean', "Delay emitting all foreign keys until the bottom of the file"],
          keywords: ['Boolean', "Quote all keywords, not just reserved words"],
          restrict: ['String', "Restrict generation to tables in the specified group (e.g. bdv, rdv)"],
          joiner: ['String', "Use 'str' instead of the default joiner between words in table and column names"],
          unicode: ['Boolean', "Use Unicode for all text fields by default"],
          tables: [%w{cap title camel snake shout}, "Case to use for table names"],
          columns: [%w{cap title camel snake shout}, "Case to use for table names"],
          # Legacy: datavault: ['String', "Generate 'raw' or 'business' data vault tables"],
        }
      end

      def initialize composition, options = {}
        @composition = composition
        @options = options
        @quote_keywords = {nil=>true, 't'=>true, 'f'=>false, 'y'=>true, 'n'=>false}[options.delete 'keywords']
        @quote_keywords = false if @keywords == nil  # Set default
        @delay_fks = options.delete "delay_fks"
        @unicode = options.delete "unicode"
        @restrict = options.delete "restrict"

        # Name configuration options:
        @joiner = options.delete('joiner')
        @table_joiner = options.has_key?('tables') ? @joiner : nil
        @table_case = ((options.delete('tables') || 'cap') + 'words').to_sym
        @table_joiner ||= [:snakewords, :shoutwords].include?(@table_case) ? '_' : ''
        @column_joiner = options.has_key?('columns') ? @joiner : nil
        @column_case = ((options.delete('columns') || 'cap') + 'words').to_sym
        @column_joiner ||= [:snakewords, :shoutwords].include?(@column_case) ? '_' : ''

        # Legacy option. Use restrict=bdv/rdv instead
        @datavault = options.delete "datavault"
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
        padding = " "*(column_name.size >= column_name_max ? 1 : column_name_max-column_name.size)
        constraints = leaf.all_leaf_constraint

        "-- #{leaf.comment}\n" +
        "\t#{column_name}#{padding}#{column_type leaf, column_name}"
      end

      def auto_assign_modifier
        ' GENERATED ALWAYS AS IDENTITY'
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
          auto_assign_modifier if a = options[:auto_assign] && a != 'assert'
        }#{
          check_clause(column_name, value_constraint) if value_constraint
        }"
      end

      def index_kind(index)
        ''
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
      def normalise_type(type_name, length, value_constraint, options)
        type = MM::DataType.normalise(type_name)

        case type
        when MM::DataType::TYPE_Boolean;  data_type_context.boolean_type
        when MM::DataType::TYPE_Integer
          # The :auto_assign key is set for auto-assigned types, but with a nil value in foreign keys
          if options.has_key?(:auto_assign)
            MM::DataType.normalise_int_length(
              'int',
              data_type_context.default_surrogate_length,
              value_constraint,
              data_type_context
            )[0]
          else
            v, = MM::DataType.normalise_int_length(type_name, length, value_constraint, data_type_context)
            v   # The typename here has the appropriate length, don't return a length
          end
        when MM::DataType::TYPE_Real;
          ["FLOAT", data_type_context.default_length(type, type_name)]
        when MM::DataType::TYPE_Decimal;  ['DECIMAL', length]
        when MM::DataType::TYPE_Money;    ['DECIMAL', length]
        when MM::DataType::TYPE_Char;     [data_type_context.default_char_type, length || data_type_context.char_default_length]
        when MM::DataType::TYPE_String;   [data_type_context.default_varchar_type, length || data_type_context.varchar_default_length]
        when MM::DataType::TYPE_Text;     [data_type_context.default_text_type, length || 'MAX']
        when MM::DataType::TYPE_Date;     'DATE' # SQLSVR 2K5: 'date'
        when MM::DataType::TYPE_Time;     'TIME' # SQLSVR 2K5: 'time'
        when MM::DataType::TYPE_DateTime; 'TIMESTAMP'
        when MM::DataType::TYPE_Timestamp;'TIMESTAMP'
        when MM::DataType::TYPE_Binary;
          if type_name =~ /^(guid|uuid)$/i && (!length || length == 16)
            length ||= 16
            if ![nil, ''].include?(options[:auto_assign])
              options.delete(:auto_assign)  # Don't auto-assign foreign keys
            end
          end
          if length
            ['BINARY', length]
          else
            ['VARBINARY', length]
          end
        else
          [type_name, length]
        end
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
        "#{s};\n\n"
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
        composite.mapping.name.words.send(@table_case)*@table_joiner
      end

      def column_name component
        words = component.column_name.send(@column_case)
        words*@column_joiner
      end

    end
    publish_generator SQL
  end
end
