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
require 'activefacts/registry'
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
      
      class CWM
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
        end

        def data_type_context
          @data_type_context ||= CWMDataTypeContext.new
        end
      
        def generate
          # @tables_emitted = {}
          @namespace = Array.new
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
      
        def nsdef name
          ns = "_#{@namespace.size + 1}"
          @namespace << [ns, name]
          ns
        end
      
        def populate_namespace_ids
          model_ns = nsdef("Model")
          schema_ns = nsdef("Schema")
          
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}.
          map{|composite| populate_table_ids(composite)}
          
          [model_ns, schema_ns]
        end
        
        def populate_table_ids(table)
          tname = table_name(table)
          table.xmiid = nsdef(tname)
          table.mapping.all_leaf.flat_map do |leaf|
            # Absorbed empty subtypes appear as leaves
            next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)
            leaf.xmiid = nsdef(safe_column_name(leaf))
          end
          table.all_index.map do |index|
            index.xmiid = nsdef("PK#{tname}")
            # for index to single column, save the index id with the column
            if index.all_index_field.size == 1
              index.all_index_field[0].component.index_xmiid = index.xmiid
            end
          end
          table.all_foreign_key_as_source_composite.map do |fk|
            fk.xmiid = nsdef("R_#{@namespace.size+1}")
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
            (table.mapping.all_leaf.flat_map do |leaf|
                # Absorbed empty subtypes appear as leaves
                next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

                generate_column(depth+2, table.xmiid, leaf)
              end
            ).compact.flat_map{|f| "#{f}" } * "" +
            indent(depth, "  </CWM:Classifier.feature>")

          table_keys =
            indent(depth, "  <CWM:Namespace.ownedElement>") +
            (table.all_index.map do |index|
                generate_index(depth+2, table.xmiid, index, name)
              end
            ) * "" +
            (table.all_foreign_key_as_source_composite.map do |fk|
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
          type_ns = nsdef(type_name)
        
          cwm_data_type = 
            "<CWMRDB:SQLSimpleType xmi.id=\"#{type_ns}\" name=\"#{type_name}\" visibility=\"public\" typeNumber=\"#{type_num}\" #{type_params}/>"
          
          @datatypes << cwm_data_type
          type_ns
        end
        
        def generate_index(depth, table_ns, index, table_name)
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
          clustering =
            (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')

          key_type = primary ? 'PrimaryKey' : 'UniqueKey'

          if column_ids.count == 1
            colid = column_ids[0]
            indent(depth, "<CWMRDB:#{key_type} xmi.id=\"#{key_ns}\" name=\"XPK#{table_name}\" visibility=\"public\" namespace=\"#{table_ns}\" feature=\"#{colid}\"/>")
          else
            indent(depth, "<CWMRDB:#{key_type} xmi.id=\"#{key_ns}\" name=\"XPK#{table_name}\" visibility=\"public\" namespace=\"#{table_ns}\">") +
            indent(depth, "  <CWM:UniqueKey.feature>") +
            column_ids.map do |id|
              indent(depth, "    <CWM:StructuralFeature xmi.idref=\"#{id}\"/>")
            end * "" +
            indent(depth, "  </CWM:UniqueKey.feature>") +
            indent(depth, "</CWMRDB:#{key_type}>")
          end
        end
        
        def generate_foreign_key(depth, table_ns, fk)
          key_ns = fk.xmiid
          
          if fk.all_foreign_key_field.size == 1
            fkf = fk.all_foreign_key_field[0]
            ixf = fk.all_index_field[0]
            indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{table_ns}\" feature=\"#{fkf.component.xmiid}\" uniqueKey=\"#{ixf.component.index_xmiid}\"/>")
          else
            indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{table_ns}\">") +
            indent(depth, "  <CWM:KeyRelationship.feature>") +
            fk.all_foreign_key_field.map do |fkf|
              indent(depth, "    <CWM:StructuralFeature xmi.idref=\"#{fkf.component.xmiid}\"/>")
            end * "" +
            indent(depth, "  </CWM:KeyRelationship.feature>") +
            indent(depth, "</CWMRDB:ForeignKey>")
          end
          # fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
          # ") REFERENCES #{safe_table_name fk.composite} (" +
          # fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
        
          # indent(depth, "<CWMRDB:ForeignKey xmi.id=\"#{key_ns}\" name=\"R#{key_ns}\" visibility=\"public\" namespace=\"#{ns}\" feature=\"_41\" uniqueKey=\"_48\" deleteRule=\"importedKeyRestrict\"  updateRule=\"importedKeyRestrict\"/>")
            
        end


      
      
        ########################
      
  


        #
        # Dump functions
        #
        # def entity_type_dump(o, level)
        #   pi = o.preferred_identifier
        #   supers = o.supertypes
        #   if (supers.size > 0) # Ignore identification by a supertype:
        #     pi = nil if pi && pi.role_sequence.all_role_ref.detect{ |rr|
        #         rr.role.fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance)
        #        }
        #   end
        #
        #   cn_array = o.concept.all_context_note_as_relevant_concept.map{|cn| [cn.context_note_kind, cn.discussion] }
        #   cn_hash = cn_array.inject({}) do |hash, value|
        #           hash[value.first] = value.last
        #           hash
        #         end
        #
        #   informal_defn = cn_hash["because"]
        #   defn_term =
        #     "              <div class=\"row\">\n" +
        #     "                <div class=\"col-md-12 definition\">\n" +
        #     "                  A #{termdef(o.name)} #{informal_defn ? 'is ' + informal_defn : ''}\n" +
        #     "                </div>\n" +
        #     "              </div>\n"
        #
        #   defn_detail =
        #     "              <div class=\"row\">\n" +
        #     "                <div class=\"col-md-12 details\">\n" +
        #     (supers.size > 0 ?
        #       "#{span('Each', 'keyword')} #{termref(o.name, nil, o)} #{span('is a kind of', 'keyword')} #{supers.map{|s| termref(s.name, nil, s)}*', '}\n" :
        #       ''
        #     ) +
        #     if pi
        #       "#{span('Each', 'keyword')} #{termref(o.name, nil, o)} #{span('is identified by', 'keyword')} " +
        #       pi.role_sequence.all_role_ref_in_order.map do |rr|
        #         termref(
        #           rr.role.object_type.name,
        #           [ rr.leading_adjective,
        #             rr.role.role_name || rr.role.object_type.name,
        #             rr.trailing_adjective
        #           ].compact * '-',
        #           rr.role.object_type
        #         )
        #       end * ", " + "\n"
        #     else
        #       ''
        #     end +
        #     fact_types_dump(o, relevant_fact_types(o)) + "\n" +
        #     "                </div>\n" +
        #     "              </div>\n"
        #
        #   defn_term + defn_detail
        # end
        #
        # def relevant_fact_types(o)
        #     o.
        #       all_role.
        #       map{|r| [r, r.fact_type]}.
        #       reject { |r, ft| ft.is_a?(ActiveFacts::Metamodel::LinkFactType) }.
        #       select { |r, ft| ft.entity_type || has_another_nonstatic_role(ft, r) }
        # end
        #
        # def has_another_nonstatic_role(ft, r)
        #   ft.all_role.detect do |rr|
        #     rr != r &&
        #     rr.object_type.is_a?(ActiveFacts::Metamodel::EntityType) &&
        #     !rr.object_type.is_static
        #   end
        # end
        #
        # def fact_types_dump(o, ftm)
        #   ftm.
        #       map { |r, ft| [ft, "    #{fact_type_dump(ft, o)}"] }.
        #       sort_by{|ft, text| [ ft.is_a?(ActiveFacts::Metamodel::TypeInheritance) ? 0 : 1, text]}.
        #       map{|ft, text| text} * "\n"
        # end
        #
        # def fact_type_dump(ft, wrt = nil)
        #   if ft.entity_type
        #     div(
        #       div(span('Each ', 'keyword') + termref(ft.entity_type.name, nil, ft.entity_type) + span(' is where ', 'keyword')) +
        #       div(expand_fact_type(ft, wrt, true, 'some')),
        #       'glossary-objectification'
        #     )
        #   else
        #     fact_type_block(ft, wrt)
        #   end
        # end
        #
        # def fact_type_block(ft, wrt = nil, include_rolenames = true)
        #   div(expand_fact_type(ft, wrt, include_rolenames, ''), 'glossary-facttype')
        # end
        #
        # def expand_fact_type(ft, wrt = nil, include_rolenames = true, wrt_qualifier = '')
        #   role = ft.all_role.detect{|r| r.object_type == wrt}
        #   preferred_reading = ft.reading_preferably_starting_with_role(role)
        #   alternate_readings = ft.all_reading.reject{|r| r == preferred_reading}
        #
        #   div(
        #     expand_reading(preferred_reading, include_rolenames, wrt, wrt_qualifier),
        #     'glossary-reading'
        #   )
        # end
        #
        # def role_ref(rr, freq_con, l_adj, name, t_adj, role_name_def, literal)
        #   term_parts = [l_adj, termref(name, nil, rr.role.object_type), t_adj].compact
        #   [
        #     freq_con ? element(freq_con, :class=>:keyword) : nil,
        #     term_parts.size > 1 ? term([l_adj, termref(name, nil, rr.role.object_type), t_adj].compact*' ') : term_parts[0],
        #     role_name_def,
        #     literal
        #   ]
        # end
        #
        # def expand_reading(reading, include_rolenames = true, wrt = nil, wrt_qualifier = '')
        #   role_refs = reading.role_sequence.all_role_ref.sort_by{|role_ref| role_ref.ordinal}
        #   lrr = role_refs[role_refs.size - 1]
        #   element(
        #     # element(rr.role.is_unique ? "one" : "some", :class=>:keyword) +
        #     reading.expand([], include_rolenames) do |rr, freq_con, l_adj, name, t_adj, role_name_def, literal|
        #       if role_name_def
        #         role_name_def = role_name_def.gsub(/\(as ([^)]+)\)/) {
        #           span("(as #{ termref(rr.role.object_type.name, $1, rr.role.object_type) })", 'keyword')
        #         }
        #       end
        #       # qualify the last role of the reading
        #       quantifier = ''
        #       if rr == lrr
        #         uniq = true
        #         (0 ... role_refs.size - 2).each{|i| uniq = uniq && role_refs[i].role.is_unique }
        #         quantifier =  uniq ? "one" : "at least one"
        #       end
        #       role_ref(rr, quantifier, l_adj, name, t_adj, role_name_def, literal)
        #     end,
        #     {:class => 'reading'}
        #   )
        # end
      

        def boolean_type
          'boolean'
        end

        def surrogate_type
          'bigint'
        end

        # def component_type component, column_name
        #   case component
        #   when MM::Indicator
        #     boolean_type
        #   when MM::SurrogateKey
        #     surrogate_type
        #   when MM::ValueField, MM::Absorption
        #     object_type = component.object_type
        #     while object_type.is_a?(MM::EntityType)
        #       rr = object_type.preferred_identifier.role_sequence.all_role_ref.single
        #       raise "Can't produce a column for composite #{component.inspect}" unless rr
        #       object_type = rr.role.object_type
        #     end
        #     raise "A column can only be produced from a ValueType" unless object_type.is_a?(MM::ValueType)
        #
        #     if component.is_a?(MM::Absorption)
        #       value_constraint ||= component.child_role.role_value_constraint
        #     end
        #
        #     supertype = object_type
        #     begin
        #       object_type = supertype
        #       length ||= object_type.length
        #       scale ||= object_type.scale
        #       unless component.parent.parent and component.parent.foreign_key
        #         # No need to enforce value constraints that are already enforced by a foreign key
        #         value_constraint ||= object_type.value_constraint
        #       end
        #     end while supertype = object_type.supertype
        #     type, length = normalise_type(object_type.name, length)
        #     sql_type = "#{type}#{
        #       if !length
        #         ''
        #       else
        #         '(' + length.to_s + (scale ? ", #{scale}" : '') + ')'
        #       end
        #     # }#{
        #     #   (component.path_mandatory ? '' : ' NOT') + ' NULL'
        #     # }#{
        #     #   # REVISIT: This is an SQL Server-ism. Replace with a standard SQL SEQUENCE/
        #     #   # Emit IDENTITY for columns auto-assigned on commit (except FKs)
        #     #   if a = object_type.is_auto_assigned and a != 'assert' and
        #     #       !component.all_foreign_key_field.detect{|fkf| fkf.foreign_key.source_composite == component.root}
        #     #     ' IDENTITY'
        #     #   else
        #     #     ''
        #     #   end
        #     }#{
        #       value_constraint ? check_clause(column_name, value_constraint) : ''
        #     }"
        #   when MM::Injection
        #     component.object_type.name
        #   else
        #     raise "Can't make a column from #{component}"
        #   end
        # end

        # def generate_index index, delayed_indices, indent
        #   nullable_columns =
        #     index.all_index_field.select do |ixf|
        #       !ixf.component.path_mandatory
        #     end
        #   contains_nullable_columns = nullable_columns.size > 0
        #
        #   primary = index.composite_as_primary_index && !contains_nullable_columns
        #   column_names =
        #       index.all_index_field.map do |ixf|
        #         column_name(ixf.component)
        #       end
        #   clustering =
        #     (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')
        #
        #   if contains_nullable_columns
        #     table_name = safe_table_name(index.composite)
        #     delayed_indices <<
        #       'CREATE UNIQUE'+clustering+' INDEX '+
        #       escape("#{table_name(index.composite)}By#{column_names*''}", index_name_max) +
        #       " ON #{table_name}("+column_names.map{|n| escape(n, column_name_max)}*', ' +
        #       ") WHERE #{
        #         nullable_columns.
        #         map{|ixf| safe_column_name ixf.component}.
        #         map{|column_name| column_name + ' IS NOT NULL'} *
        #         ' AND '
        #       }"
        #     nil
        #   else
        #     # '-- '+index.inspect
        #     "  " * indent + (primary ? 'PRIMARY KEY' : 'UNIQUE') +
        #     clustering +
        #     "(#{column_names.map{|n| escape(n, column_name_max)}*', '})"
        #   end
        # end

        # def generate_foreign_key fk, indent
        #   # '-- '+fk.inspect
        #   "  " * indent + "FOREIGN KEY (" +
        #     fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
        #     ") REFERENCES <a href=\"#LDMD_#{table_name fk.composite}\">#{table_name fk.composite}</a> (" +
        #     fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
        #   ")"
        # end

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

        # def go s = ''
        #   "#{s}\nGO\n"  # REVISIT: This is an SQL-Serverism. Move it to a subclass.
        # end

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
