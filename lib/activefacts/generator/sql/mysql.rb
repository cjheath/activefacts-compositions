#
#       ActiveFacts MySQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
# Reserved words gathered from:
# https://dev.mysql.com/doc/refman/5.7/en/keywords.html
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
      class MySQL < SQL
        def self.options
          super.merge({
            # no: [String, "no new options defined here"]
          })
        end

        def table_name_max
          64
        end

        def data_type_context
          MySQLDataTypeContext.new
        end

        def auto_assign_modifier
          ' AUTO_INCREMENT'
        end

        def generate_schema
          ''
        end

        def normalise_type(type_name, length, value_constraint, options)
          type = MM::DataType.normalise(type_name)
          case type
          when MM::DataType::TYPE_Integer
            if aa = options[:auto_assign]
              'BIGINT'
            else
              super
            end
          when MM::DataType::TYPE_Money;    ['DECIMAL', length]
          when MM::DataType::TYPE_DateTime; 'DATETIME'
          when MM::DataType::TYPE_Timestamp;'DATETIME'
          when MM::DataType::TYPE_Binary;
            if type_name =~ /^(guid|uuid)$/i && (!length || length == 16)
              if ![nil, ''].include?(options[:auto_assign])
                options[:default] = " DEFAULT UNHEX(REPLACE(UUID(),'-',''))"
                options.delete(:auto_assign)  # Don't auto-assign foreign keys
              end
              return ['BINARY', 16]
            end

            super type_name, length, value_constraint, options
            # MySQL has various non-standard blob types also
          else
            super
          end
        end

        # Reserved words cannot be used anywhere without quoting.
        # Keywords have existing definitions, so should not be used without quoting.
        # Both lists here are added to the supertype's lists
        def reserved_words
          @mysql_reserved_words ||= %w{
            ACCESSIBLE ANALYZE CHANGE DATABASE DATABASES DAY_HOUR
            DAY_MICROSECOND DAY_MINUTE DAY_SECOND DELAYED DISTINCTROW
            DIV DUAL ENCLOSED ESCAPED EXPLAIN FLOAT4 FLOAT8 FORCE
            FULLTEXT HIGH_PRIORITY HOUR_MICROSECOND HOUR_MINUTE
            HOUR_SECOND INDEX INFILE INT1 INT2 INT3 INT4 INT8
            IO_AFTER_GTIDS IO_BEFORE_GTIDS KEYS KILL LINEAR LINES
            LOAD LOCK LONG LONGBLOB LONGTEXT LOW_PRIORITY MASTER_BIND
            MASTER_SSL_VERIFY_SERVER_CERT MEDIUMBLOB MEDIUMINT
            MEDIUMTEXT MIDDLEINT MINUTE_MICROSECOND MINUTE_SECOND
            NO_WRITE_TO_BINLOG OPTIMIZE OPTIMIZER_COSTS OPTIONALLY
            OUTFILE PURGE READ_WRITE REGEXP RENAME REPLACE REQUIRE
            RLIKE SCHEMAS SECOND_MICROSECOND SEPARATOR SHOW SPATIAL
            SQL_BIG_RESULT SQL_CALC_FOUND_ROWS SQL_SMALL_RESULT SSL
            STARTING STORED STRAIGHT_JOIN TERMINATED TINYBLOB TINYINT
            TINYTEXT UNLOCK UNSIGNED USE UTC_DATE UTC_TIME UTC_TIMESTAMP
            VARCHARACTER VIRTUAL XOR YEAR_MONTH ZEROFILL _FILENAME
          }
          super + @mysql_reserved_words
        end

        def key_words
          # These keywords should not be used for columns or tables:
          @mysql_key_words ||= %w{
            ACCOUNT AGAINST AGGREGATE ALGORITHM ANALYSE ASCII
            AUTOEXTEND_SIZE AUTO_INCREMENT AVG_ROW_LENGTH BACKUP
            BINLOG BLOCK BOOL BTREE BYTE CACHE CHANGED CHANNEL
            CHARSET CHECKSUM CIPHER CLIENT CODE COLUMN_FORMAT COMMENT
            COMPACT COMPLETION COMPRESSED COMPRESSION CONCURRENT
            CONSISTENT CONTEXT CPU DATAFILE DATETIME DEFAULT_AUTH
            DELAY_KEY_WRITE DES_KEY_FILE DIRECTORY DISABLE DISCARD
            DISK DUMPFILE DUPLICATE ENABLE ENCRYPTION ENDS ENGINE
            ENGINES ENUM ERROR ERRORS EVENT EVENTS EXCHANGE EXPANSION
            EXPIRE EXPORT EXTENDED EXTENT_SIZE FAST FAULTS FIELDS
            FILE_BLOCK_SIZE FIXED FLUSH FOLLOWS FORMAT GEOMETRY
            GEOMETRYCOLLECTION GET_FORMAT GRANTS GROUP_REPLICATION
            HASH HELP HOST HOSTS IDENTIFIED IGNORE_SERVER_IDS INDEXES
            INITIAL_SIZE INSERT_METHOD INSTALL IO IO_THREAD IPC
            ISSUER JSON KEY_BLOCK_SIZE LEAVES LESS LINESTRING LIST
            LOCKS LOGFILE LOGS MASTER MASTER_AUTO_POSITION
            MASTER_CONNECT_RETRY MASTER_DELAY MASTER_HEARTBEAT_PERIOD
            MASTER_HOST MASTER_LOG_FILE MASTER_LOG_POS MASTER_PASSWORD
            MASTER_PORT MASTER_RETRY_COUNT MASTER_SERVER_ID MASTER_SSL
            MASTER_SSL_CA MASTER_SSL_CAPATH MASTER_SSL_CERT
            MASTER_SSL_CIPHER MASTER_SSL_CRL MASTER_SSL_CRLPATH
            MASTER_SSL_KEY MASTER_TLS_VERSION MASTER_USER
            MAX_CONNECTIONS_PER_HOUR MAX_QUERIES_PER_HOUR MAX_ROWS
            MAX_SIZE MAX_STATEMENT_TIME MAX_UPDATES_PER_HOUR
            MAX_USER_CONNECTIONS MEDIUM MEMORY MICROSECOND MIGRATE
            MIN_ROWS MODE MODIFY MULTILINESTRING MULTIPOINT
            MULTIPOLYGON MUTEX MYSQL_ERRNO NDB NDBCLUSTER NEVER
            NODEGROUP NONBLOCKING NO_WAIT NVARCHAR OLD_PASSWORD ONE
            OWNER PACK_KEYS PAGE PARSER PARSE_GCOL_EXPR PARTITIONING
            PARTITIONS PASSWORD PHASE PLUGIN PLUGINS PLUGIN_DIR
            POINT POLYGON PORT PREV PROCESSLIST PROFILE PROFILES
            PROXY QUARTER QUERY QUICK READ_ONLY REBUILD RECOVER
            REDOFILE REDO_BUFFER_SIZE REDUNDANT RELAY RELAYLOG
            RELAY_LOG_FILE RELAY_LOG_POS RELAY_THREAD RELOAD REMOVE
            REORGANIZE REPAIR REPLICATE_DO_DB REPLICATE_DO_TABLE
            REPLICATE_IGNORE_DB REPLICATE_IGNORE_TABLE REPLICATE_REWRITE_DB
            REPLICATE_WILD_DO_TABLE REPLICATE_WILD_IGNORE_TABLE
            REPLICATION RESET RESUME REVERSE ROTATE ROW_FORMAT RTREE
            SCHEDULE SERIAL SHARE SHUTDOWN SIGNED SLAVE SLOW SNAPSHOT
            SOCKET SONAME SOUNDS SQL_AFTER_GTIDS SQL_AFTER_MTS_GAPS
            SQL_BEFORE_GTIDS SQL_BUFFER_RESULT SQL_CACHE SQL_NO_CACHE
            SQL_THREAD SQL_TSI_DAY SQL_TSI_HOUR SQL_TSI_MINUTE
            SQL_TSI_MONTH SQL_TSI_QUARTER SQL_TSI_SECOND SQL_TSI_WEEK
            SQL_TSI_YEAR STACKED STARTS STATS_AUTO_RECALC
            STATS_PERSISTENT STATS_SAMPLE_PAGES STATUS STOP STORAGE
            STRING SUBJECT SUBPARTITION SUBPARTITIONS SUPER SUSPEND
            SWAPS SWITCHES TABLES TABLESPACE TABLE_CHECKSUM TEMPTABLE
            TEXT THAN TIMESTAMPADD TIMESTAMPDIFF TRIGGERS TYPES
            UNDEFINED UNDOFILE UNDO_BUFFER_SIZE UNICODE UNINSTALL
            UPGRADE USER_RESOURCES USE_FRM VALIDATION VARIABLES
            WAIT WARNINGS WEEK WEIGHT_STRING X509 XA XID
          }

          super + @mysql_key_words
        end

        def go s = ''
          "#{s};\n\n"
        end

        def open_escape
          '`'
        end

        def close_escape
          '`'
        end

        def index_kind(index)
          ''
        end

        class MySQLDataTypeContext < SQLDataTypeContext
          def integer_ranges
            [
              ['TINYINT', -2**7, 2**7-1],
              ['TINYINT UNSIGNED', 0, 2**8-1], 
              ['MEDIUMINT', -2**23, 2**23-1], 
            ] + super
          end

          def boolean_type
            'BOOLEAN'
          end

          def valid_from_type
            'DATETIME'  # The TIMESTAMP type starts in 1970
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
    publish_generator SQL::MySQL
  end
end
