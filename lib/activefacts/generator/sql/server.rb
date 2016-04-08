#
#       ActiveFacts Standard SQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
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

        def auto_assign_type
          ' IDENTITY'
        end

        def normalise_type(type_name, length, value_constraint)
          return ['UNIQUEIDENTIFIER', 16] if type_name =~ /^(guid|uuid)$/i

          type = MM::DataType.normalise(type_name)
          case type
          when MM::DataType::TYPE_Money;    'MONEY'
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

        def reserved_words
          @reserved_words ||= %w{
            ADD ALL ALTER AND ANY AS ASC AUTHORIZATION BACKUP BEGIN
            BETWEEN BREAK BROWSE BULK BY CASCADE CASE CHECK CHECKPOINT
            CLOSE CLUSTERED COALESCE COLLATE COLUMN COMMIT COMPUTE
            CONSTRAINT CONTAINS CONTAINSTABLE CONTINUE CONVERT CREATE
            CROSS CURRENT CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP
            CURRENT_USER CURSOR DATABASE DBCC DEALLOCATE DECLARE
            DEFAULT DELETE DENY DESC DISK DISTINCT DISTRIBUTED DOUBLE
            DROP DUMMY DUMP ELSE END ERRLVL ESCAPE EXCEPT EXEC EXECUTE
            EXISTS EXIT FETCH FILE FILLFACTOR FOR FOREIGN FREETEXT
            FREETEXTTABLE FROM FULL FUNCTION GOTO GRANT GROUP HAVING
            HOLDLOCK IDENTITY IDENTITYCOL IDENTITY_INSERT IF IN INDEX
            INNER INSERT INTERSECT INTO IS JOIN KEY KILL LEFT LIKE
            LINENO LOAD NATIONAL NOCHECK NONCLUSTERED NOT NULL NULLIF
            OF OFF OFFSETS ON OPEN OPENDATASOURCE OPENQUERY OPENROWSET
            OPENXML OPTION OR ORDER OUTER OVER PERCENT PLAN PRECISION
            PRIMARY PRINT PROC PROCEDURE PUBLIC RAISERROR READ READTEXT
            RECONFIGURE REFERENCES REPLICATION RESTORE RESTRICT RETURN
            REVOKE RIGHT ROLLBACK ROWCOUNT ROWGUIDCOL RULE SAVE SCHEMA
            SELECT SESSION_USER SET SETUSER SHUTDOWN SOME STATISTICS
            SYSTEM_USER TABLE TEXTSIZE THEN TO TOP TRAN TRANSACTION
            TRIGGER TRUNCATE TSEQUAL UNION UNIQUE UPDATE UPDATETEXT
            USE USER VALUES VARYING VIEW WAITFOR WHEN WHERE WHILE
            WITH WRITETEXT
          }
        end

        def go s = ''
          "#{s}\nGO\n"
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
