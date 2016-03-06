#
#       ActiveFacts Logical Data Model Generator
#
# This generator produces an HTML-formated Logical Data Model of a Vocabulary.
#
# Copyright (c) 2016 Infinuendo. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'byebug'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore 
    class LDM < GLOSSARY
      def self.options
        {
          underscore: [String, "Use 'str' instead of underscore between words in table names"]
        }
      end

      def initialize composition, options = {}
        @composition = composition
        @options = options
        @underscore = options.has_key?("underscore") ? (options['underscore'] || '_') : ''
        
        @vocabulary = composition.constellation.Vocabulary.values[0]      # REVISIT when importing from other vocabularies
        # glossary_options = {"gen_bootstrap" => true}
        # @glossary = GLOSSARY.new(@vocabulary, glossary_options)
      end

      def generate
        @tables_emitted = {}
        @delayed_foreign_keys = []
        
        trace.enable 'ldm'

        generate_header +
        generate_definitions +
        generate_diagrams +
        generate_details +
        generate_footer
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

      def generate_header
        css_file = "/css/ldm.css"
        
        "<!DOCTYPE html>\n" +
        "<html lang=\"en\">\n" + 
        "  <head>\n" +
        "    <meta charset=\"utf-8\">\n" +
        "    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n" +
        "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
        "    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->\n" + 
        "    <title>Logical Data Model for " + @composition.name + "</title>\n" + 
        "\n" +
        "    <!-- Bootstrap -->\n" +
        "    <link href=\"css/bootstrap.min.css\" rel=\"stylesheet\">\n" +
        "\n" +
        "    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->\n" +
        "    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->\n" +
        "    <!--[if lt IE 9]>\n" + 
        "      <script src=\"https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js\"></script>\n" +
        "      <script src=\"https://oss.maxcdn.com/respond/1.4.2/respond.min.js\"></script>\n" +
        "    <![endif]-->\n" +
        File.open(File.dirname(__FILE__)+css_file) do |f|
          "    <style media='screen' type='text/css'>\n" +
          f.read + "\n" +
          "    </style>\n"
        end +
        "  </head>\n" +
        "  <body>\n" +
        "    <div class=\"container\">\n" +
        "      <div class=\"row\">\n" +
        "        <div class=\"col-md-12\">\n" +
        "          <h1>Logical Data Model for " + @composition.name + "</h2>\n"
      end

      def generate_definitions
        all_top_object_type =
          @vocabulary.
            all_object_type.
            reject{|o| o.kind_of?(ActiveFacts::Metamodel::TypeInheritance)}.
            reject{|o| o.kind_of?(ActiveFacts::Metamodel::ValueType)}.
            select{|o| o.fact_type || o.supertypes.size == 0}.
            sort_by{|o| o.name.gsub(/ /,'').downcase}
            
        "            <h2>Business Definitons and Relationships</h2>\n" +
        # "<dl class=\"dl-horizontal\">\n" +
        all_top_object_type.
          map do |o|
            
            # byebug
            
            # REVISIT case statement was not matching ActiveFacts::Metamodel::ValueType
            if o.kind_of?(ActiveFacts::Metamodel::TypeInheritance) then
              ''
            elsif o.kind_of?(ActiveFacts::Metamodel::ValueType) then
              '' # @glossary.value_type_dump(o, false, false, false)
            elsif o.fact_type
              objectified_fact_type_dump(o)
            else
              entity_type_dump(o, 0)
            end
          end * "\n" + "\n"
        # "</dl>\n"
      end 
      
      def generate_diagrams
        ''
      end
      
      def generate_details 
        "              <h2>Logical Data Model Details</h2>\n" +
        @composition.
        all_composite.
        sort_by{|composite| composite.mapping.name}.
        map{|composite| generate_table composite}*"\n" + "\n"
      end
      
      def generate_footer
        "            </div>\n" +
        "        </div>\n" +
        "      </div>\n" +
        "    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->\n" +
        "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js\"></script>\n" +
        "    <!-- Include all compiled plugins (below), or include individual files as needed -->\n" +
        "    <script src=\"js/bootstrap.min.js\"></script>\n" +
        # @glossary.glossary_end +
        "  </body>\n" +
        "</html>\n"
      end

      def objectified_fact_type_dump(o)
        defn_term =
          "              <div class=\"row row-bordered\">\n" +
          "                <div class=\"col-md-3 definition\">\n" +
          "                  #{termdef(o.name)}\n" +
          "                </div>\n"

        defn_detail =
          "              <div class=\"col-md-9\">\n" +
          # @glossary.fact_type_with_constraints(o.fact_type, false, nil, false) + "\n" +
          fact_type_with_constraints(o.fact_type, false, nil, false) + "\n" +

          # o.fact_type.all_role_in_order.map do |r|
          #   n = r.object_type.name
          #   div("#{termref(o.name)} involves #{span('one', 'keyword')} #{termref(r.role_name || n, n)}", "glossary-facttype")
          # end * "\n" + "\n" +
          # @glossary.relevant_facts_and_constraints(o, false, false, false) + "\n" +
          relevant_facts_and_constraints(o, false, false, false) + "\n" +
          "              </div>\n" +
          "            </div>\n"

          defn_term + defn_detail
      end

      def entity_type_dump(o, level)
        pi = o.preferred_identifier
        supers = o.supertypes
        if (supers.size > 0) # Ignore identification by a supertype:
          pi = nil if pi && pi.role_sequence.all_role_ref.detect{|rr| rr.role.fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance) }
        end

        defn_term =
          "              <div class=\"row row-bordered\">\n" +
          "                <div class=\"col-md-3 definition\" style=\"padding-left: #{level*30+15}px\">\n" +
          "                  #{termdef(o.name)}\n" +
          "              </div>\n"

        defn_detail =
          "                <div class=\"col-md-9\">\n" +
          (supers.size > 0 ? "#{span('is a kind of', 'keyword')} #{supers.map{|s| termref(s.name)}*', '}\n" : '') +
          if pi
            "#{span('is identified by', 'keyword')} " +
            pi.role_sequence.all_role_ref_in_order.map do |rr|
              termref(
                rr.role.object_type.name,
                [ rr.leading_adjective,
                  rr.role.role_name || rr.role.object_type.name,
                  rr.trailing_adjective
                ].compact * '-'
              )
            end * ", " + "\n"
          else
            ''
          end +
          relevant_facts_and_constraints(o, false, false, false) + "\n" +
          "                </div>\n" +
          "              </div>\n"
        
        subtype_object_type =
          @vocabulary.
            all_object_type.
            reject{|so| so.kind_of?(ActiveFacts::Metamodel::TypeInheritance)}.
            reject{|so| so.kind_of?(ActiveFacts::Metamodel::ValueType)}.
            reject{|so| so.fact_type}.
            select{|so| so.supertypes.size > 0 && so.supertypes[0].name == o.name }.
            sort_by{|so| so.name.gsub(/ /,'').downcase}
                      
        subtype_dump =
          subtype_object_type.map { |o| entity_type_dump(o, level+1) } * "\n" + "\n"
        
        defn_term + defn_detail + subtype_dump
      end


      def generate_table composite
        @tables_emitted[composite] = true
        delayed_indices = []

        "                <h3 id=\"LDMD_#{table_name(composite)}\">#{composite.mapping.name}</h3>\n" +
        "                  <table class=\"table table-bordered table-striped\">\n" +
        "                    <thead style=\"background-color: #aaa;\">\n" +
        "                      <tr>\n" +
        "                        <th>Attribute</th><th>M/O</th><th>Description</th>\n" +
        "                      </tr>\n" +
        "                    </thead>\n" +
        "                    <tbody>\n" +
        (
          composite.mapping.leaves.flat_map do |leaf|
            # Absorbed empty subtypes appear as leaves
            next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

            generate_column leaf, 11
          end
        ).compact.flat_map{|f| "#{f}" }*"\n"+"\n" +
        # (
      #     composite.all_index.map do |index|
      #       generate_index index, delayed_indices
      #     end.compact.sort +
      #     composite.all_foreign_key_as_source_composite.map do |fk|
      #       fk_text generate_foreign_key fk
      #       if !@delay_fks and @tables_emitted[fk.composite]
      #         fk_text
      #       else
      #         @delayed_foreign_keys <<
      #           go("ALTER TABLE #{safe_table_name fk.composite}\n\tADD " + fk_text)
      #         nil
      #       end
      #     end.compact.sort +
      #     composite.all_local_constraint.map do |constraint|
      #       '-- '+constraint.inspect    # REVISIT: Emit local constraints
      #     end
      #   ).compact.flat_map{|f| "\t#{f}" }*",\n"+"\n" +
      #   go(")") +
      #   delayed_indices.sort.map do |delayed_index|
      #     go delayed_index
        # end*"\n"
        "                    </tbody>\n" +
        "                  </table>\n" +
        (
          composite.all_index.map do |index|
            generate_index index, delayed_indices, 9
          end.compact.sort +
          composite.all_foreign_key_as_source_composite.map do |fk|
            # trace :ldm, "generate foreign key for #{fk.composite.mapping.name}"
            generate_foreign_key fk, 9
          end.compact.sort
        ).compact.flat_map{|f| "#{f}" }*"<br>\n"+"\n"
      end

      def generate_column leaf, indent
        column_name = safe_column_name(leaf)
        padding = " "*(column_name.size >= column_name_max ? 1 : column_name_max-column_name.size)
        constraints = leaf.all_leaf_constraint

        identity = ''
        
        "  " * indent + "<tr>\n" +
        "  " * indent + "  <td>#{column_name}\n" +
        "  " * indent + "  <td>#{leaf.path_mandatory ? 'M' : 'O'}\n" +
        "  " * indent + "  <td>#{column_comment leaf}\n" +
        "  " * indent + "</tr>" 
        # "-- #{column_comment leaf}\n\t#{column_name}#{padding}#{component_type leaf, column_name}#{identity}"
      end

      def column_comment component
        return '' unless cp = component.parent
        prefix = column_comment(cp)
        name = component.name
        if component.is_a?(MM::Absorption)
          reading = component.parent_role.fact_type.reading_preferably_starting_with_role(component.parent_role).expand([], false)
          maybe = component.parent_role.is_mandatory ? '' : 'maybe '
          cpname = cp.name
          if prefix[(-cpname.size-1)..-1] == ' '+cpname && reading[0..cpname.size] == cpname+' '
            prefix+' that ' + maybe + reading[cpname.size+1..-1]
          else
            (prefix.empty? ? '' : prefix+' and ') + maybe + reading
          end
        else
          name
        end
      end

      def boolean_type
        'BOOLEAN'
      end

      def surrogate_type
        'BIGINT IDENTITY NOT NULL'
      end

      def component_type component, column_name
        case component
        when MM::Indicator
          boolean_type
        when MM::SurrogateKey
          surrogate_type
        when MM::ValueField, MM::Absorption
          object_type = component.object_type
          while object_type.is_a?(MM::EntityType)
            rr = object_type.preferred_identifier.role_sequence.all_role_ref.single
            raise "Can't produce a column for composite #{component.inspect}" unless rr
            object_type = rr.role.object_type
          end
          raise "A column can only be produced from a ValueType" unless object_type.is_a?(MM::ValueType)

          if component.is_a?(MM::Absorption)
            value_constraint ||= component.child_role.role_value_constraint
          end

          supertype = object_type
          begin
            object_type = supertype
            length ||= object_type.length
            scale ||= object_type.scale
            unless component.parent.parent and component.parent.foreign_key
              # No need to enforce value constraints that are already enforced by a foreign key
              value_constraint ||= object_type.value_constraint
            end
          end while supertype = object_type.supertype
          type, length = normalise_type(object_type.name, length)
          sql_type = "#{type}#{
            if !length
              ''
            else
              '(' + length.to_s + (scale ? ", #{scale}" : '') + ')'
            end
          }#{
            (component.path_mandatory ? '' : ' NOT') + ' NULL'
          }#{
            # REVISIT: This is an SQL Server-ism. Replace with a standard SQL SEQUENCE/
            # Emit IDENTITY for columns auto-assigned on commit (except FKs)
            if a = object_type.is_auto_assigned and a != 'assert' and
                !component.all_foreign_key_field.detect{|fkf| fkf.foreign_key.source_composite == component.root}
              ' IDENTITY'
            else
              ''
            end
          }#{
            value_constraint ? check_clause(column_name, value_constraint) : ''
          }"
        when MM::Injection
          component.object_type.name
        else
          raise "Can't make a column from #{component}"
        end
      end

      def generate_index index, delayed_indices, indent
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
          # '-- '+index.inspect
          "  " * indent + (primary ? 'PRIMARY KEY' : 'UNIQUE') +
          clustering +
          "(#{column_names.map{|n| escape(n, column_name_max)}*', '})"
        end
      end

      def generate_foreign_key fk, indent
        # '-- '+fk.inspect
        "  " * indent + "FOREIGN KEY (" +
          fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
          ") REFERENCES <a href=\"#LDMD_#{table_name fk.composite}\">#{table_name fk.composite}</a> (" +
          fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
        ")"
      end

      def reserved_words
        @sql_server_reserved_words ||= %w{
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
        "#{s}\nGO\n"  # REVISIT: This is an SQL-Serverism. Move it to a subclass.
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

      # Return SQL type and (modified?) length for the passed base type
      def normalise_type(type, length)
        sql_type = case type
          when /^Auto ?Counter$/
            'int'

          when /^Unsigned ?Integer$/,
            /^Signed ?Integer$/,
            /^Unsigned ?Small ?Integer$/,
            /^Signed ?Small ?Integer$/,
            /^Unsigned ?Tiny ?Integer$/
            s = case
              when length == nil
                'int'
              when length <= 8
                'tinyint'
              when length <= 16
                'smallint'
              when length <= 32
                'int'
              else
                'bigint'
              end
            length = nil
            s

          when /^Decimal$/
            'decimal'

          when /^Fixed ?Length ?Text$/, /^Char$/
            'char'
          when /^Variable ?Length ?Text$/, /^String$/
            'varchar'
          when /^Large ?Length ?Text$/, /^Text$/
            'text'

          when /^Date ?And ?Time$/, /^Date ?Time$/
            'datetime'
          when /^Date$/
            'datetime' # SQLSVR 2K5: 'date'
          when /^Time$/
            'datetime' # SQLSVR 2K5: 'time'
          when /^Auto ?Time ?Stamp$/
            'timestamp'

          when /^Guid$/
            'uniqueidentifier'
          when /^Money$/
            'decimal'
          when /^Picture ?Raw ?Data$/, /^Image$/
            'image'
          when /^Variable ?Length ?Raw ?Data$/, /^Blob$/
            'varbinary'
          when /^BIT$/
            'bit'
          else type # raise "SQL type unknown for standard type #{type}"
          end
        [sql_type, length]
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

      MM = ActiveFacts::Metamodel
    end
    publish_generator LDM
  end
end
