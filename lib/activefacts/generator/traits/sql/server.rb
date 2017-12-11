#
#       ActiveFacts SQL Server Traits
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://technet.microsoft.com/en-us/library/ms189822(v=sql.110).aspx
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/traits/sql'

module ActiveFacts
  module Generators
    module Traits
      module SQL
        module Server
          include Traits::SQL

          def options
            super.merge({
              # no: [String, "no new options defined here"]
            })
          end

          # The options parameter overrides any default options set by sub-traits
          def defaults_and_options options
            super
          end

          def process_options options
            # No extra options to process
            super
            @closed_world_indices = true
          end

          def data_type_context_class
            SQLServerDataTypeContext
          end

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
            128
          end

          def schema_prefix
            ''
          end

          def choose_sql_type(type_name, value_constraint, component, options)
            type = MM::DataType.intrinsic_type(type_name)
            case type
            when MM::DataType::TYPE_Integer
              # The :auto_assign key is set for auto-assigned types, but with a nil value in foreign keys
              if options.has_key?(:auto_assign)
                options[:default] = ' IDENTITY' if options[:auto_assign]
                'BIGINT'
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
              length = options[:length]
              case binary_surrogate(type_name, value_constraint, options)
              when :guid_fk             # A GUID surrogate that's auto-assigned elsewhere
                'UNIQUEIDENTIFIER'
              when :guid                # A GUID
                options[:default] = " DEFAULT NEWID()"
                # NEWSEQUENTIALID improves indexing locality and page fill factor.
                # However, it makes values more easily guessable, and
                # exposes the MAC address of the generating computer(!)
                # options[:default] = " DEFAULT NEWSEQUENTIALID()"
                'UNIQUEIDENTIFIER'
              when :hash                # A hash of the natural key
                options[:length] = 20   # Assuming SHA-1. SHA-256 would need 32 bytes
                options[:computed] = hash_assignment(component, component.root.natural_index.all_index_field.map(&:component))
                'BINARY'
              else                      # Not a surrogate
                length = options[:length]
                if length && length <= 8192
                  super
                else
                  'IMAGE'
                end
              end
            else
              super
            end
          end

          def create_or_replace(name, kind)
            # From SQL Server 2016 onwards, you can use "CREATE OR ALTER ..."
            go("IF OBJECT_ID('#{name}') IS NOT NULL\n\tDROP #{kind} #{name}") +
            "CREATE #{kind} #{name}"
          end

          def hash_assignment hash_field, leaves
            table_name = safe_table_name(hash_field.root)
            trigger_function = escape('assign_'+column_name(hash_field), 128)
            %Q{
            AS #{hash(concatenate(coalesce(as_text(safe_column_exprs(leaves)))))}
            PERSISTED}.gsub(/\s+/,' ').strip
          end

          # Some or all of the SQL expressions may have non-text values.
          # Return an SQL expression that coerces them to text.
          def as_text exprs
            return exprs.map{|e| as_text(e)} if Array === exprs

            return exprs.map{|e| as_text(e)} if Array === exprs

            style =
              case exprs.type_num
              when MM::DataType::TYPE_Date, MM::DataType::TYPE_DateTime, MM::DataType::TYPE_Timestamp
                ', 121'
              # REVISIT: What about MM::DataType::TYPE_Time?
              else
                ''
              end
            Expression.new("CONVERT(VARCHAR, #{exprs}#{style})", MM::DataType::TYPE_String, exprs.is_mandatory)
          end

          # Return an SQL expression that concatenates the given expressions (which must be text)
          def concatenate exprs
            # SQL Server 2012 onwards: %Q{CONCAT('|'+#{exprs.flat_map{|e| [e.to_s, "+'|'"]}*''})}
            Expression.new(
              %Q{('|'+#{
                exprs.flat_map{|e| [e.to_s, "'|'"] } * '+'
                })},
              MM::DataType::TYPE_String,
              true
            )
          end

          # Return an expression that yields a hash of the given expression
          def hash expr, algo = 'SHA1'
            Expression.new("CONVERT(BINARY(32), HASHBYTES('#{algo}', #{expr}), 2)", MM::DataType::TYPE_Binary, expr.is_mandatory)
          end

          # Reserved words cannot be used anywhere without quoting.
          # Keywords have existing definitions, so should not be used without quoting.
          # Both lists here are added to the supertype's lists
          def reserved_words
            @sqlserver_reserved_words ||= %w{
              BACKUP BREAK BROWSE BULK CHECKPOINT CLUSTERED COMPUTE
              CONTAINSTABLE DATABASE DBCC DENY DISK DISTRIBUTED DUMP
              ERRLVL FILE FILLFACTOR FREETEXT FREETEXTTABLE HOLDLOCK
              IDENTITYCOL IDENTITY_INSERT INDEX KILL LINENO LOAD
              NOCHECK NONCLUSTERED OFF OFFSETS OPENDATASOURCE OPENQUERY
              OPENROWSET OPENXML PIVOT PLAN PRINT PROC RAISERROR
              READTEXT RECONFIGURE REPLICATION RESTORE REVERT ROWCOUNT
              ROWGUIDCOL RULE SAVE SECURITYAUDIT SEMANTICKEYPHRASETABLE
              SEMANTICSIMILARITYDETAILSTABLE SEMANTICSIMILARITYTABLE
              SETUSER SHUTDOWN STATISTICS TEXTSIZE TOP TRAN TRY_CONVERT
              TSEQUAL UNPIVOT UPDATETEXT USE WAITFOR WITHIN GROUP
              WRITETEXT
            }
            super + @sqlserver_reserved_words
          end

          def key_words
            # These keywords should not be used for columns or tables:
            @sqlserver_key_words ||= %w{
              INCLUDE INDEX SQLCA
            }
            super + @sqlserver_key_words
          end

          # Although SQL Server accepts ; as a statement separator,
          # it runs commands in batches when the "GO" command is issued.
          def go s = ''
            "#{s.sub(/\A\n+/,'')}\nGO\n"
          end

          def open_escape
            '['
          end

          def close_escape
            ']'
          end

          def index_kind(index)
            (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')
          end

          class SQLServerDataTypeContext < SQLDataTypeContext
            def integer_ranges
              [
                ['BIT', 0, 1],
                ['TINYINT', -2**7, 2**7-1],
              ] +
              super
            end

            def boolean_type
              'BIT'
            end

            def boolean_expr safe_column_name
              "{safe_column_name} = 1"
            end

            def valid_from_type
              'DATETIME'
            end

            def default_char_type
              (@unicode ? 'N' : '') +
              'CHAR'
            end

            def default_varchar_type
              (@unicode ? 'N' : '') +
              'VARCHAR'
            end

            def date_time_type
              'DATETIME'
            end
          end

          def cast_as_string d
            # select right('0000000000'+cast(1234.45 as varchar(10)), 11);  -- Only good for +ve numbers!
            # set @x = -12345;
            # select right('0000000000'+convert(varchar(10), 1234.45, style), 11);  -- Use styles
            # select convert(varchar, GETDATE(), 21); -- 'YYYY-MM-DD HH:mm:ss.123'
            #
            # declare @x decimal(10,3);
            # set @x = -12345.67;
            # select case when @x < 0 then '-'+right('0000000000'+cast(-@x as varchar(10)), 11)
            #        else ' '+right('0000000000'+cast(@x as varchar(10)), 11)
            #        end;
            #
            # declare @x money; set @x = 123.456; select CONVERT(varchar, @x, 0);
            #
            # declare @x float; set @x = 123.456; select CONVERT(varchar, @x, 2); -- Always 16 characters, exponential notation
          end

        end

      end
    end
  end
end
