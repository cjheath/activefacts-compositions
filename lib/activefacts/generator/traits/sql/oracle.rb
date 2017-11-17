#
#       ActiveFacts Oracle SQL Traits
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://docs.oracle.com/cd/B28359_01/appdev.111/b31231/appb.htm
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/traits/sql'

module ActiveFacts
  module Generators
    module Traits
      # Options are comma or space separated:
      # * underscore 
      module SQL
        module Oracle
          include Traits::SQL

          # Options available in this flavour of SQL
          def options
            super.merge({
              # no: [String, "no new options defined here"]
            })
          end

          # The options parameter overrides any default options set by sub-traits
          def defaults_and_options options
            {'tables' => 'shout', 'columns' => 'shout'}.merge(options)
          end

          def process_options options
            super
          end

          def data_type_context_class
            OracleDataTypeContext
          end

          # See https://docs.oracle.com/database/122/NEWFT/new-features.htm
          # Identifier lengths were 30 *bytes* prior to Oracle 12C
          def table_name_max
            128
          end

          def column_name_max
            128
          end

          def index_name_max
            128
          end

          def schema_name_max
            128   # Was 8 characters
          end

          def schema_prefix
            ''
          end

          def auto_increment_modifier
            ' GENERATED BY DEFAULT ON NULL AS IDENTITY'
          end

          def index_kind(index)
            super
          end

          def normalise_type(type_name, length, value_constraint, options)
            type = MM::DataType.normalise(type_name)
            case type
            when MM::DataType::TYPE_Integer
              if aa = options[:auto_assign]
                'LONGINTEGER'
              else
                super
              end

            when MM::DataType::TYPE_Money
              'MONEY'

            when MM::DataType::TYPE_DateTime
              'DATETIME'

            when MM::DataType::TYPE_Timestamp
              'DATETIME'

            when MM::DataType::TYPE_Binary
              if aa = normalise_binary_as_guid(type_name, length, value_constraint, options)
                if aa == :auto_assign
                  options[:default] = " DEFAULT SYS_GUID()"
                end
                return ['RAW', 32]
              end
              ['LOB', length]
            else
              super
            end
          end

          # Reserved words cannot be used anywhere without quoting.
          # Keywords have existing definitions, so should not be used without quoting.
          # Both lists here are added to the supertype's lists
          def reserved_words
            @oracle_reserved_words ||= %w{
              ACCESS ARRAYLEN AUDIT CLUSTER COMMENT COMPRESS EXCLUSIVE
              IDENTIFIED INDEX INITIAL LOCK LONG MAXEXTENTS MINUS
              MODE MODIFY NOAUDIT NOCOMPRESS NOTFOUND NOWAIT OFFLINE
              ONLINE PCTFREE RAW RENAME RESOURCE ROWID ROWLABEL ROWNUM
              SHARE SQLBUF SUCCESSFUL SYNONYM SYSDATE UID VALIDATE
              VARCHAR2
            }
            @oracle_plsql_reserved_words ||= %w{
              ABORT ACCEPT ACCESS ARRAYLEN ASSERT ASSIGN BASE_TABLE
              BINARY_INTEGER BODY CHAR_BASE CLUSTER CLUSTERS COLAUTH
              COMPRESS CONSTANT CRASH CURRVAL DATABASE DATA_BASE DBA
              DEBUGOFF DEBUGON DEFINITION DELAY DELTA DIGITS DISPOSE
              ELSIF ENTRY EXCEPTION_INIT FORM GENERIC IDENTIFIED INDEX
              INDEXES LIMITED MINUS MLSLABEL MODE NEXTVAL NOCOMPRESS
              NUMBER_BASE PACKAGE PCTFREE POSITIVE PRAGMA PRIVATE
              RAISE RECORD REMR RENAME RESOURCE REVERSE ROWID ROWLABEL
              ROWNUM ROWTYPE RUN SEPARATE SQLERRM STDDEV SUBTYPE
              TABAUTH TABLES TASK TERMINATE USE VARCHAR2 VARIANCE
              VIEWS XOR
            }
            super + @oracle_reserved_words
          end

          def key_words
            # These keywords should not be used for columns or tables:
            @oracle_key_words ||= %w{
              ANALYZE ARCHIVE ARCHIVELOG BACKUP BECOME BLOCK BODY
              CACHE CANCEL CHANGE CHECKPOINT COMPILE CONTENTS CONTROLFILE
              DATABASE DATAFILE DBA DISABLE DISMOUNT DUMP ENABLE
              EVENTS EXCEPTIONS EXPLAIN EXTENT EXTERNALLY FLUSH FORCE
              FREELIST FREELISTS INITRANS LAYER LISTS LOGFILE MANAGE
              MANUAL MAXDATAFILES MAXINSTANCES MAXLOGFILES MAXLOGHISTORY
              MAXLOGMEMBERS MAXTRANS MINEXTENTS MOUNT NOARCHIVELOG
              NOCACHE NOCYCLE NOMAXVALUE NOMINVALUE NOORDER NORESETLOGS
              NORMAL NOSORT OPTIMAL OWN PACKAGE PARALLEL PCTINCREASE
              PCTUSED PLAN PRIVATE PROFILE QUOTA RECOVER RESETLOGS
              RESTRICTED REUSE ROLES SCN SEGMENT SHARED SNAPSHOT SORT
              STATEMENT_ID STATISTICS STOP STORAGE SWITCH TABLES
              TABLESPACE THREAD TRACING TRIGGERS UNLIMITED USE
            }
            super + @oracle_key_words
          end

          def go s = ''
            super
          end

          def open_escape
            '"'
          end

          def close_escape
            '"'
          end

          def index_kind(index)
            ''
          end

          class OracleDataTypeContext < SQLDataTypeContext
            def integer_ranges
              [
                ['SHORTINTEGER', -2**15, 2**15-1],  # The standard says -10^5..10^5 (less than 16 bits)
                ['INTEGER', -2**31, 2**31-1],   # The standard says -10^10..10^10 (more than 32 bits!)
                ['LONGINTEGER', -2**63, 2**63-1],    # The standard says -10^19..10^19 (less than 64 bits)
              ]
            end

            # PL/SQL has a BOOLEAN type, but Oracle databases do not, see
            # https://docs.oracle.com/database/121/LNPLS/datatypes.htm#LNPLS348
            def boolean_type
              'CHAR(1)'   # Probably should put a CHECK '0' or '1' here
            end

            # Ugly, but safe (Oracle's internal schema tables use 'Y' and 'N'):
            def boolean_expr safe_column_name
              "(#{safe_column_name} = '1' OR #{safe_column_name} = 'Y')"
            end

            def valid_from_type
              date_time_type
            end

            # There is no performance benefit in using fixed-length CHAR fields,
            # and an added burden of trimming the implicitly added white-space
            def default_char_type
              (@unicode ? 'N' : '') +
              'VARCHAR'
            end

            def default_varchar_type
              (@unicode ? 'N' : '') +
              'VARCHAR'
            end

            def date_time_type
              'TIMESTAMP'
            end
          end
        end

      end
    end
  end
end
