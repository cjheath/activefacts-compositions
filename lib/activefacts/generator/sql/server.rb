#
#       ActiveFacts SQL Server Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://technet.microsoft.com/en-us/library/ms189822(v=sql.110).aspx
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
      class Server < SQL
        def self.options
          super.merge({
            # no: [String, "no new options defined here"]
          })
        end

        def table_name_max
          128
        end

        def data_type_context
          SQLServerDataTypeContext.new
        end

        def auto_assign_modifier
          ' IDENTITY'
        end

        def normalise_type(type_name, length, value_constraint, options)
          type = MM::DataType.normalise(type_name)
          case type
          when MM::DataType::TYPE_Money;    'MONEY'
          when MM::DataType::TYPE_DateTime; 'DATETIME'
          when MM::DataType::TYPE_Timestamp;'DATETIME'
          when MM::DataType::TYPE_Binary;
            if type_name =~ /^(guid|uuid)$/i && (!length || length == 16)
              if ![nil, ''].include?(options[:auto_assign])
                options[:default] = ' DEFAULT NEWID()'
                options.delete(:auto_assign)
              end
              return 'UNIQUEIDENTIFIER'
            end
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

        def go s = ''
          "#{s}\nGO\n"
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
      end

    end
    publish_generator SQL::Server
  end
end
