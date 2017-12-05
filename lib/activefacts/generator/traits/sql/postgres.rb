#
#       ActiveFacts PostgreSQL Traits
#
# Copyright (c) 2017 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://www.postgresql.org/docs/9.5/static/sql-keywords-appendix.html
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/traits/sql'

module ActiveFacts
  module Generators
    module Traits
      module SQL
        module Postgres
          prepend Traits::SQL

          def options
            super.merge({
              # no: [String, "no new options defined here"]
            })
          end

          # The options parameter overrides any default options set by sub-traits
          def defaults_and_options options
            {'tables' => 'snake', 'columns' => 'snake'}.merge(options)
          end

          def process_options options
            # No extra options to process
            super
          end

          def data_type_context_class
            PostgresDataTypeContext
          end

          def table_name_max
            63
          end

          def column_name_max
            63
          end

          def index_name_max
            63
          end

          def schema_name_max
            63
          end

          def schema_prefix
            go("CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public") +
            "\n"
          end

          def choose_sql_type(type_name, value_constraint, component, options)
            type = MM::DataType.intrinsic_type(type_name)
            case type
            when MM::DataType::TYPE_Integer
              # The :auto_assign key is set for auto-assigned types, but with a nil value in foreign keys
              if options.has_key?(:auto_assign)
                if options[:auto_assign]
                  'BIGSERIAL' # This doesn't need an auto_increment default
                else
                  'BIGINT'
                end
              else
                super
              end

            when MM::DataType::TYPE_Money
              'MONEY'

            when MM::DataType::TYPE_DateTime
              'TIMESTAMP'

            when MM::DataType::TYPE_Timestamp
              'TIMESTAMP'

            when MM::DataType::TYPE_Binary
              case binary_surrogate(type_name, value_constraint, options)
              when :guid_fk             # A surrogate that's auto-assigned elsewhere
                options[:length] = nil
                'UUID'
              when :guid                # A GUID
                # This requires the pgcrypto extension
                options[:length] = nil
                options[:default] = " DEFAULT 'gen_random_uuid()'"
                'UUID'
              when :hash                # A hash of the natural key
                options.delete(:length) # 20 bytes, assuming SHA-1, but we don't need to specify it. SHA-256 would need 32 bytes
                options[:delayed] = trigger_hash_assignment(component, component.root.natural_index.all_index_field.map(&:component))
                'BYTEA'
              else                      # Not a surrogate
                options.delete(:length)
                'BYTEA'
              end

            else
              super
            end
          end

          # Return an array of SQL statements that arrange for the hash_field
          # to be populated with a hash of the values of the leaves.
          def trigger_hash_assignment hash_field, leaves
            table_name = safe_table_name(hash_field.root)
            trigger_function = escape('assign_'+column_name(hash_field), 128)
            [
              %Q{
                CREATE OR REPLACE FUNCTION #{trigger_function}() RETURNS TRIGGER AS $$
                BEGIN
                        NEW.#{safe_column_name(hash_field)} = #{
                          hash(concatenate(coalesce(as_text(safe_column_exprs(leaves, 'NEW')))))
                        };
                        RETURN NEW;
                END
                $$ language 'plpgsql'}.
              unindent,
              %Q{
                CREATE TRIGGER trig_#{trigger_function}
                        BEFORE INSERT OR UPDATE ON #{table_name}
                        FOR EACH ROW EXECUTE PROCEDURE #{trigger_function}()}.
              unindent
            ]
          end

          # Some or all of the SQL expressions may have non-text values.
          # Return an SQL expression that coerces them to text.
          def as_text exprs
            return exprs.map{|e| as_text(e)} if Array === exprs

            Expression.new("#{exprs}::text", MM::DataType::TYPE_String, exprs.is_mandatory)
          end

          # Return an SQL expression that concatenates the given expressions (which must yield a string type)
          def concatenate expressions
            Expression.new(
              "'|'::text || " +
              expressions.map(&:to_s) * " || '|'::text || " +
              " || '|'::text",
              MM::DataType::TYPE_String,
              true
            )
          end

          # Return an expression that yields a hash of the given expression
          def hash expr, algo = 'sha1'
            Expression.new("digest(#{expr}, '#{algo}')", MM::DataType::TYPE_Binary, expr.is_mandatory)
          end

          def truncate expr, length
            Expression.new("substring(#{expr} for #{length})", MM::DataType::TYPE_String, expr.is_mandatory)
          end

          # Produce a lexically-sortable decimal representation of the given numeric expression, to the overall specified length and scale
          def lexical_decimal expr, length, scale = 0
            fraction_pattern = scale > 0 ? '.'+'0'*scale : ''
            Expression.new(
              "to_char(#{expr}, 'MI#{'0'*(length-fraction_pattern.length-1)+fraction_pattern})",
              MM::DataType::TYPE_String,
              expr.is_mandatory
            )
          end

          def lexical_date expr
            Expression.new("to_char(#{expr}, 'YYYY-MM-DD')", MM::DataType::TYPE_String, expr.is_mandatory)
          end

          def lexical_datetime expr
            Expression.new("to_char(#{expr}, 'YYYY-MM-DD HH24:MI:SS.US')", MM::DataType::TYPE_String, expr.is_mandatory)
          end

          def lexical_time expr
            Expression.new("to_char(#{expr}, 'HH24:MI:SS.US')", MM::DataType::TYPE_String, expr.is_mandatory)
          end

          def as_alpha expr
            Expression.new("btrim(lower(regexp_replace(#{expr}, '[^[:alnum:]]+', ' ', 'g')))", MM::DataType::TYPE_String, expr.is_mandatory)
          end

          def phonetics expr
            [
              Expression.new("dmetaphone(#{expr})", MM::DataType::TYPE_String, expr.is_mandatory),
              Expression.new("dmetaphone_alt(#{expr})", MM::DataType::TYPE_String, expr.is_mandatory)
            ]
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

            # See https://www.postgresql.org/docs/9.0/static/datatype-boolean.html
            def boolean_expr safe_column_name
              safe_column_name  # psql outputs as 't' or 'f', but the bare column is a boolean expression
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
    end
  end
end
