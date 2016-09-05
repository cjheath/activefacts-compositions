#
#       ActiveFacts Common Warehouse Metamodel Generator
#
# This generator produces an CWM XMI-formated model of a Composition.
#
# Copyright (c) 2016 Infinuendo. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/metamodel/datatypes'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/support'

module ActiveFacts
  module Generators
    module Doc
      
      # Add namespace id to metamodel forward referencing     
      class ActiveFacts::Metamodel::Composite       # for tables
        attr_accessor   :xmiid
      end
      
      class ActiveFacts::Metamodel::Absorption      # for columns
        attr_accessor   :xmiid
        attr_accessor   :index_xmiid
      end
      
      class ActiveFacts::Metamodel::Indicator
        attr_accessor   :xmiid
      end
      
      class ActiveFacts::Metamodel::Index           # for primary and unique indexes
        attr_accessor   :xmiid
      end
      
      class ActiveFacts::Metamodel::ForeignKey      # for foreign keys
        attr_accessor   :xmiid
      end
      
      class ActiveFacts::Metamodel::ValueField
        attr_accessor   :xmiid
        attr_accessor   :index_xmiid
      end
      
      class CWM      
        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
        def self.options
          {
            underscore: [String, "Use 'str' instead of underscore between words in table names"]
          }
        end

        def initialize compositions, options = {}
          raise "--cwm only processes a single composition" if compositions.size > 1
          @composition = compositions[0]
          @options = options
          @underscore = options.has_key?("underscore") ? (options['underscore'] || '_') : ''

          @vocabulary = @composition.constellation.Vocabulary.values[0]      # REVISIT when importing from other vocabularies
        end

        def data_type_context
          @data_type_context ||= CWMDataTypeContext.new
        end

        def generate
          # @tables_emitted = {}
          @ns = 0
          @datatypes = Array.new

          trace.enable 'cwm'

          model_ns, schema_ns = populate_namespace_ids

          generate_header +
          generate_content(model_ns, schema_ns) +
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

        def indent depth, str
          "  " * depth + str + "\n"
        end

        def rawnsdef
          @ns += 1
          "_#{@ns}"
        end

        def nsdef obj, pref = nil
          if obj.xmiid == nil
            obj.xmiid = "#{pref}#{rawnsdef}"
          end
          obj.xmiid
        end

        def populate_namespace_ids
          model_ns = rawnsdef
          schema_ns = rawnsdef
          
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}.
          map{|composite| populate_table_ids(composite)}
          
          [model_ns, schema_ns]
        end
        
        def populate_table_ids(table)
          tname = table_name(table)
          nsdef(table)
          table.mapping.all_leaf.flat_map do |leaf|
            # Absorbed empty subtypes appear as leaves
            next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)
            nsdef(leaf)
          end
          table.all_index.map do |index|
            nsdef(index)
            index.all_index_field.map{|idf| idf.component.index_xmiid = index.xmiid}
          end
          table.all_foreign_key_as_source_composite.sort_by{|fk| [fk.source_composite.mapping.name, fk.absorption.inspect] }.map do |fk|
            nsdef(fk)
          end
        end
        
        def generate_header
          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
          "<!DOCTYPE XMI SYSTEM \"CWM-1.1.dtd\">\n" +
          "\n" +
          "<XMI xmlns:CWM=\"org.omg.CWM1.1\" xmlns:CWMRDB=\"org.omg.CWM1.1/Relational\" xmi.version=\"1.1\">\n" +
          "  <XMI.header>\n" +
          "    <XMI.documentation>\n" +
          "      <XMI.exporter>Infinuedo APRIMO</XMI.exporter>\n" +
          "      <XMI.exporterVersion>0.1</XMI.exporterVersion>\n" +
          "    </XMI.documentation>\n" +
          "    <XMI.metamodel xmi.name=\"CWM\" xmi.version=\"1.1\" />" +
          "  </XMI.header>\n"
        end

        def generate_content(model_ns, schema_ns)
          "  <XMI.content>\n" +
          generate_catalog(2, model_ns, schema_ns) +
          generate_data_types(2) +
          "  </XMI.content>\n"
        end
            
        def generate_footer
          "</XMI>\n"
        end
      
        def generate_catalog(depth, model_ns, schema_ns)
          catalog_start =
            indent(depth, "<CWMRDB:Catalog xmi.id=\"#{model_ns}\" name=\"Model\" visibility=\"public\">") +
            indent(depth, "  <CWM:Namespace.ownedElement>") +
            indent(depth, "    <CWMRDB:Schema xmi.id=\"#{schema_ns}\" name=\"Schema\" visibility=\"public\" namespace=\"#{model_ns}\">") +
            indent(depth, "      <CWM:Namespace.ownedElement>")

          catalog_body = 
            @composition.
            all_composite.
            sort_by{|composite| composite.mapping.name}.
            map{|composite| generate_table(depth+4, schema_ns, composite)}*"\n" + "\n"
        
          catalog_end =
            indent(depth, "      </CWM:Namespace.ownedElement>") +
            indent(depth, "    </CWMRDB:Schema>") +
            indent(depth, "  </CWM:Namespace.ownedElement>") +
            indent(depth, "</CWMRDB:Catalog>")
        
          catalog_start + catalog_body + catalog_end
        end
      
        def generate_data_types(depth)
          @datatypes.map do | dt |
            indent(depth, dt)
          end * ""
        end
      
        def generate_table(depth, schema_ns, table)
          name = table_name(table)
          delayed_indices = []
        
          table_start =
            indent(depth, "<CWMRDB:Table xmi.id=\"#{table.xmiid}\" name=\"#{name}\" isSystem=\"false\" isTemporary=\"false\" visibility=\"public\" namespace=\"#{schema_ns}\">")
          
          table_columns =
            indent(depth, "  <CWM:Classifier.feature>") +
            (table.mapping.all_leaf.flat_map.sort_by{|c| column_name(c)}.map do |leaf|
                # Absorbed empty subtypes appear as leaves
                next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

                generate_column(depth+2, table.xmiid, leaf)
              end
            ).compact.flat_map{|f| "#{f}" } * "" +
            indent(depth, "  </CWM:Classifier.feature>")

          table_keys =
            indent(depth, "  <CWM:Namespace.ownedElement>") +
            (table.all_index.map do |index|
                generate_index(depth+2, table.xmiid, index, name, table.all_foreign_key_as_target_composite)
              end
            ) * "" +
            (table.all_foreign_key_as_source_composite.sort_by{|fk| [fk.source_composite.mapping.name, fk.absorption.inspect] }.map do |fk|
                generate_foreign_key(depth+2, table.xmiid, fk)
              end
            ) * "" +
            indent(depth, "  </CWM:Namespace.ownedElement>")
  
          table_end =
            indent(depth, "</CWMRDB:Table>")
          
          table_start + table_columns + table_keys + table_end
        end

        def generate_column(depth, table_ns, column)
          name = safe_column_name(column)
        
          is_nullable = column.path_mandatory ? "columnNoNulls" : "columnNullable"
          constraints = column.all_leaf_constraint

          type_name, options = column.data_type(data_type_context)
          options ||= {}
          length = options[:length]
          
          type_name, type_num = normalise_type_cwm(type_name, length)
          column_params = ""
          type_params = ""

          type_ns = create_data_type(type_name, type_num, type_params)

          indent(depth, "<CWMRDB:Column xmi.id=\"#{column.xmiid}\" name=\"#{name}\" isNullable=\"#{is_nullable}\" visibility=\"public\" type=\"#{type_ns}\" owner=\"#{table_ns}\" #{column_params}/>")
        end

        def create_data_type(type_name, type_num, type_params)
          type_ns = rawnsdef
        
          cwm_data_type = 
            "<CWMRDB:SQLSimpleType xmi.id=\"#{type_ns}\" name=\"#{type_name}\" visibility=\"public\" typeNumber=\"#{type_num}\" #{type_params}/>"
          
          @datatypes << cwm_data_type
          type_ns
        end
        
        def generate_index(depth, table_ns, index, table_name, all_fks_as_target)
          key_ns = index.xmiid

          nullable_columns =
            index.all_index_field.select do |ixf|
              !ixf.component.path_mandatory
            end
          contains_nullable_columns = nullable_columns.size > 0

          primary = index.composite_as_primary_index && !contains_nullable_columns
          column_ids =
            index.all_index_field.map do |ixf|
              ixf.component.xmiid
            end
          # clustering =
          #   (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')

          key_type = primary ? 'CWMRDB:PrimaryKey' : 'CWM:UniqueKey'
          
          # find target foreign keys for this index
          fks_as_target = all_fks_as_target

          if column_ids.count == 1 && fks_as_target.count == 0
            colid = column_ids[0]
            indent(depth, "<#{key_type} xmi.id=\"#{key_ns}\" name=\"XPK#{table_name}\" visibility=\"public\" namespace=\"#{table_ns}\" feature=\"#{colid}\"/>")
          else
            if column_ids.count == 1
              colid = column_ids[0]
              indent(depth, "<#{key_type} xmi.id=\"#{key_ns}\" name=\"XPK#{table_name}\" visibility=\"public\" namespace=\"#{table_ns}\" feature=\"#{colid}\">")
            else
              indent(depth, "<#{key_type} xmi.id=\"#{key_ns}\" name=\"XPK#{table_name}\" visibility=\"public\" namespace=\"#{table_ns}\">") +
              indent(depth, "  <CWM:UniqueKey.feature>") +
              column_ids.map do |id|
                indent(depth, "    <CWM:StructuralFeature xmi.idref=\"#{id}\"/>")
              end * "" +
              indent(depth, "  </CWM:UniqueKey.feature>")
            end +
            if fks_as_target.count > 0
              indent(depth, "<CWM:UniqueKey.keyRelationship>") +
              fks_as_target.map do |fk|
                indent(depth, " <CWM:KeyRelationship xmi.idref=\"#{fk.xmiid}\"/>") 
              end * "" +
              indent(depth, "</CWM:UniqueKey.keyRelationship>")
            else
              ""
            end +
            indent(depth, "</#{key_type}>")
          end
        end
        
        def generate_foreign_key(depth, table_ns, fk)
          key_ns = fk.xmiid
          
          if fk.all_foreign_key_field.size == 1
            fkf = fk.all_foreign_key_field[0]
            ixf = fk.all_index_field[0]
            indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{table_ns}\" feature=\"#{fkf.component.xmiid}\" uniqueKey=\"#{ixf.component.index_xmiid}\" />")
          else
            indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{table_ns}\">") +
            indent(depth, "  <CWM:KeyRelationship.feature>") +
            begin
              out = ""
              for i in 0..(fk.all_foreign_key_field.size - 1)
                fkf = fk.all_foreign_key_field[i]
                ixf = fk.all_index_field[i]
                out += indent(depth, "    <CWM:StructuralFeature xmi.idref=\"#{fkf.component.xmiid}\" uniqueKey=\"#{ixf.component.index_xmiid}\" />")
              end
              out
            end + 
            indent(depth, "  </CWM:KeyRelationship.feature>") +
            indent(depth, "</CWMRDB:ForeignKey>")
          end
          # fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
          # ") REFERENCES #{safe_table_name fk.composite} (" +
          # fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
        
          # indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{ns}\" feature=\"_41\" uniqueKey=\"_48\" deleteRule=\"importedKeyRestrict\"  updateRule=\"importedKeyRestrict\"/>")
            
        end

        def boolean_type
          'boolean'
        end

        def surrogate_type
          'bigint'
        end


        def reserved_words
          @reserved_words ||= %w{ }
        end

        def is_reserved_word w
          @reserved_word_hash ||=
            reserved_words.inject({}) do |h,w|
              h[w] = true
              h
            end
          @reserved_word_hash[w.upcase]
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

        # Return CWM type, typenum for the passed base type
        def normalise_type_cwm(type_name, length)
          type = MM::DataType.normalise(type_name)

          case type
          when MM::DataType::TYPE_Boolean;  ['boolean', 16]
          when MM::DataType::TYPE_Integer
            case type_name
            when /^Auto ?Counter$/i
              ['int', 4]
            when /([a-z ]|\b)Tiny([a-z ]|\b)/i
              ['tinyint', -6]
            when /([a-z ]|\b)Small([a-z ]|\b)/i,
              /([a-z ]|\b)Short([a-z ]|\b)/i
              ['smallint', 5]
            when /([a-z ]|\b)Big(INT)?([a-z ]|\b)/i
              ['bigint', -5]
            else
              ['int', 4]
            end
          when MM::DataType::TYPE_Real;
            ['real', 7, data_type_context.default_length(type, type_name)]
          when MM::DataType::TYPE_Decimal;  ['decimal', 3]
          when MM::DataType::TYPE_Money;    ['decimal', 3]
          when MM::DataType::TYPE_Char;     ['char', 12, length || data_type_context.char_default_length]
          when MM::DataType::TYPE_String;   ['varchar', 12, length || data_type_context.varchar_default_length]
          when MM::DataType::TYPE_Text;     ['text', 2005, length || 'MAX']
          when MM::DataType::TYPE_Date;     ['date', 91]
          when MM::DataType::TYPE_Time;     ['time', 92]
          when MM::DataType::TYPE_DateTime; ['datetime', 93]
          when MM::DataType::TYPE_Timestamp;['timestamp', -3]
          when MM::DataType::TYPE_Binary;
            length ||= 16 if type_name =~ /^(guid|uuid)$/i
            if length
              ['BINARY', -2]
            else
              ['VARBINARY', -2]
            end
          else
            ['int', 4]
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

        class CWMDataTypeContext < MM::DataType::Context
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
        
      end
    end
    publish_generator Doc::CWM
  end
end
