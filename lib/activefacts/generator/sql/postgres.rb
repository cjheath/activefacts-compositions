#
#       ActiveFacts PostgreSQL Schema Generator
#
# Copyright (c) 2017 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://www.postgresql.org/docs/9.5/static/sql-keywords-appendix.html
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/sql'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * underscore 
    class SQL
      class Postgres < SQL
        def self.options
          super.merge({
            # no: [String, "no new options defined here"]
          })
        end

        def initialize composition, options = {}
          super(composition, {'tables' => 'snake', 'columns' => 'snake'}.merge(options))
        end

        def table_name_max
          63
        end

        def data_type_context
          PostgresDataTypeContext.new
        end

        def auto_increment_modifier
          ''
        end

        def generate_schema
          go "CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public"
        end

        def normalise_type(type_name, length, value_constraint, options)
          if type_name =~ /^(guid|uuid)$/i
            if ![nil, ''].include?(options[:auto_assign])
              options[:default] = " DEFAULT 'gen_random_uuid()'"
            end
            return ['UUID']
          end

          type = MM::DataType.normalise(type_name)
          case type
          when MM::DataType::TYPE_Integer
            if aa = options[:auto_assign]
              if aa.size > 0
                'BIGSERIAL'
              else
                'BIGINT'
              end
            else
              super
            end
          when MM::DataType::TYPE_Money;    'MONEY'
          when MM::DataType::TYPE_DateTime; 'TIMESTAMP'
          when MM::DataType::TYPE_Timestamp;'TIMESTAMP'
          when MM::DataType::TYPE_Binary;
            if length && length <= 8192
              super
            else
              'IMAGE'
            end
          else
            super
          end
        end

        # Reserved words cannot be used anywhere without quoting.
        # Keywords have existing definitions, so should not be used without quoting.
        # Both lists here are added to the supertype's lists
        def reserved_words
          @postgres_reserved_words ||= %w{
            ANALYSE ANALYZE LIMIT PLACING RETURNING VARIADIC
          }
          super + @postgres_reserved_words
        end

        def key_words
          # These keywords should not be used for columns or tables:
          @postgres_key_words ||= %w{
            ABORT ACCESS AGGREGATE ALSO BACKWARD CACHE CHECKPOINT
            CLASS CLUSTER COMMENT COMMENTS CONFIGURATION CONFLICT
            CONVERSION COPY COST CSV DATABASE DELIMITER DELIMITERS
            DICTIONARY DISABLE DISCARD ENABLE ENCRYPTED ENUM EVENT
            EXCLUSIVE EXPLAIN EXTENSION FAMILY FORCE FORWARD FUNCTIONS
            HEADER IMMUTABLE IMPLICIT INDEX INDEXES INHERIT INHERITS
            INLINE LABEL LEAKPROOF LISTEN LOAD LOCK LOCKED LOGGED
            MATERIALIZED MODE MOVE NOTHING NOTIFY NOWAIT OIDS
            OPERATOR OWNED OWNER PARSER PASSWORD PLANS POLICY
            PREPARED PROCEDURAL PROGRAM QUOTE REASSIGN RECHECK
            REFRESH REINDEX RENAME REPLACE REPLICA RESET RULE
            SEQUENCES SHARE SHOW SKIP SNAPSHOT STABLE STATISTICS
            STDIN STDOUT STORAGE STRICT SYSID TABLES TABLESPACE
            TEMP TEMPLATE TEXT TRUSTED TYPES UNENCRYPTED UNLISTEN
            UNLOGGED VACUUM VALIDATE VALIDATOR VIEWS VOLATILE
          }

          # These keywords cannot be used for type or functions (and should not for columns or tables)
          @postgres_key_words_func_type ||= %w{
            GREATEST LEAST SETOF XMLROOT 
          }
          super + @postgres_key_words + @postgres_key_words_func_type
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

        def index_kind(index)
          ''
        end

        class PostgresDataTypeContext < SQLDataTypeContext
          def integer_ranges
            super
          end

          def boolean_type
            'BOOLEAN'
          end

          def valid_from_type
            'TIMESTAMP'
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
    publish_generator SQL::Postgres
  end
end
