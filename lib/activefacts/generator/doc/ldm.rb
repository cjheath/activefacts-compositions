#
#       ActiveFacts Logical Data Model Generator
#
# This generator produces an HTML-formated Logical Data Model of a Vocabulary.
#
# Copyright (c) 2016 Infinuendo. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/support'

module ActiveFacts
  module Generators
    module Doc
      class LDM
        def self.options
          {
            underscore: [String, "Use 'str' instead of underscore between words in table names"]
          }
        end

        def initialize compositions, options = {}, compositor_klass_names = []
          raise "--ldm only processes a single composition" if compositions.size > 1
          @composition = compositions[0]
          @options = options
          @underscore = options.has_key?("underscore") ? (options['underscore'] || '_') : ''

          @vocabulary = composition.constellation.Vocabulary.values[0]      # REVISIT when importing from other vocabularies
          # glossary_options = {"gen_bootstrap" => true}
          # @glossary = GLOSSARY.new(@vocabulary, glossary_options)
        end

        def generate
          @tables_emitted = {}

          # trace.enable 'ldm'

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
          "    <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\" integrity=\"sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7\" crossorigin=\"anonymous\">\n" +
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
          h1("Logical Data Model for " + @composition.name)
        end

        def generate_definitions
          defns =
            @composition.
              all_composite.
              reject {|c| c.mapping.object_type.is_a?(ActiveFacts::Metamodel::ValueType)}.
              reject {|c| c.mapping.object_type.is_static}.
              reject {|c| c.mapping.object_type.fact_type}.
              map {|c| c.mapping.object_type}

          @definitions = {}
          defns.each do |o|
            @definitions[o] = true
          end

          defns.each do |o|
            ftm = relevant_fact_types(o)

            trace :ldm, "expanding #{o.name}"

            ftm.each do |r, ft|
              next if ft.is_a?(ActiveFacts::Metamodel::TypeInheritance)
              ft.all_role.each do |ftr|
                next if @definitions[ftr.object_type]
                next if ftr.object_type.is_a?(ActiveFacts::Metamodel::ValueType)

                trace :ldm, "adding #{ftr.object_type.name}"

                defns = defns << ftr.object_type
                @definitions[ftr.object_type] = true
              end
            end
          end

          "            <h2>Business Definitions and Relationships</h2>\n" +
          defns.sort_by{|o| o.name.gsub(/ /, '').downcase}.map do |o|
            entity_type_dump(o, 0)
          end * "\n" + "\n"
        end

        def generate_diagrams
          ''
        end

        def generate_details
          h2("Logical Data Model Details") +
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}.
          map{|composite| generate_table(composite)}*"\n" + "\n"
        end

        def generate_footer
          "            </div>\n" +
          "        </div>\n" +
          "      </div>\n" +
          "    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->\n" +
          "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js\"></script>\n" +
          "    <!-- Include all compiled plugins (below), or include individual files as needed -->\n" +
          "    <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\" integrity=\"sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS\" crossorigin=\"anonymous\"></script>\n" +
          # @glossary.glossary_end +
          "  </body>\n" +
          "</html>\n"
        end

        #
        # Standard document elements
        #
        def element(text, attrs, tag = 'span')
          "<#{tag}#{attrs.empty? ? '' : attrs.map{|k,v| " #{k}='#{v}'"}*''}>#{text}</#{tag}>"
        end

        def span(text, klass = nil)
          element(text, klass ? {:class => klass} : {})
        end

        def div(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'div')
        end

        def h1(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'h1')
        end

        def h2(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'h2')
        end

        def h3(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'h3')
        end

        def dl(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'dl')
        end

        # A definition of a term
        def termdef(name)
          element(name, {:name => name, :class => 'object_type'}, 'a')
        end

        # A reference to a defined term (excluding role adjectives)
        def termref(name, role_name = nil, o = nil)
          if o && !@definitions[o]
            element(name, :class=>:object_type)
          else
            role_name ||= name
            element(role_name, {:href=>'#'+name, :class=>:object_type}, 'a')
          end
        end

        # Text that should appear as part of a term (including role adjectives)
        def term(name)
          element(name, :class=>:object_type)
        end

        #
        # Dump functions
        #
        def entity_type_dump(o, level)
          pi = o.preferred_identifier
          supers = o.supertypes
          if (supers.size > 0) # Ignore identification by a supertype:
            pi = nil if pi && pi.role_sequence.all_role_ref.detect{ |rr|
                rr.role.fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance)
               }
          end

          cn_array = o.concept.all_context_note_as_relevant_concept.map{|cn| [cn.context_note_kind, cn.discussion] }
          cn_hash = cn_array.inject({}) do |hash, value|
                  hash[value.first] = value.last
                  hash
                end

          informal_defn = cn_hash["because"]
          defn_term =
            "              <div class=\"row\">\n" +
            "                <div class=\"col-md-12 definition\">\n" +
            "                  A #{termdef(o.name)} #{informal_defn ? 'is ' + informal_defn : ''}\n" +
            "                </div>\n" +
            "              </div>\n"

          defn_detail =
            "              <div class=\"row\">\n" +
            "                <div class=\"col-md-12 details\">\n" +
            (supers.size > 0 ?
              "#{span('Each', 'keyword')} #{termref(o.name, nil, o)} #{span('is a kind of', 'keyword')} #{supers.map{|s| termref(s.name, nil, s)}*', '}\n" :
              ''
            ) +
            if pi
              "#{span('Each', 'keyword')} #{termref(o.name, nil, o)} #{span('is identified by', 'keyword')} " +
              pi.role_sequence.all_role_ref_in_order.map do |rr|
                termref(
                  rr.role.object_type.name,
                  [ rr.leading_adjective,
                    rr.role.role_name || rr.role.object_type.name,
                    rr.trailing_adjective
                  ].compact * '-',
                  rr.role.object_type
                )
              end * ", " + "\n"
            else
              ''
            end +
            fact_types_dump(o, relevant_fact_types(o)) + "\n" +
            "                </div>\n" +
            "              </div>\n"

          defn_term + defn_detail
        end

        def relevant_fact_types(o)
            o.
              all_role.
              map{|r| [r, r.fact_type]}.
              reject { |r, ft| ft.is_a?(ActiveFacts::Metamodel::LinkFactType) }.
              select { |r, ft| ft.entity_type || has_another_nonstatic_role(ft, r) }
        end

        def has_another_nonstatic_role(ft, r)
          ft.all_role.detect do |rr|
            rr != r &&
            rr.object_type.is_a?(ActiveFacts::Metamodel::EntityType) &&
            !rr.object_type.is_static
          end
        end

        def fact_types_dump(o, ftm)
          ftm.
              map { |r, ft| [ft, "    #{fact_type_dump(ft, o)}"] }.
              sort_by{|ft, text| [ ft.is_a?(ActiveFacts::Metamodel::TypeInheritance) ? 0 : 1, text]}.
              map{|ft, text| text} * "\n"
        end

        def fact_type_dump(ft, wrt = nil)
          if ft.entity_type
            div(
              div(span('Each ', 'keyword') + termref(ft.entity_type.name, nil, ft.entity_type) + span(' is where ', 'keyword')) +
              div(expand_fact_type(ft, wrt, true, 'some')),
              'glossary-objectification'
            )
          else
            fact_type_block(ft, wrt)
          end
        end

        def fact_type_block(ft, wrt = nil, include_rolenames = true)
          div(expand_fact_type(ft, wrt, include_rolenames, ''), 'glossary-facttype')
        end

        def expand_fact_type(ft, wrt = nil, include_rolenames = true, wrt_qualifier = '')
          role = ft.all_role.detect{|r| r.object_type == wrt}
          preferred_reading = ft.reading_preferably_starting_with_role(role)
          alternate_readings = ft.all_reading.reject{|r| r == preferred_reading}

          div(
            expand_reading(preferred_reading, include_rolenames, wrt, wrt_qualifier),
            'glossary-reading'
          )
        end

        def role_ref(rr, freq_con, l_adj, name, t_adj, role_name_def, literal)
          term_parts = [l_adj, termref(name, nil, rr.role.object_type), t_adj].compact
          [
            freq_con ? element(freq_con, :class=>:keyword) : nil,
            term_parts.size > 1 ? term([l_adj, termref(name, nil, rr.role.object_type), t_adj].compact*' ') : term_parts[0],
            role_name_def,
            literal
          ]
        end

        def expand_reading(reading, include_rolenames = true, wrt = nil, wrt_qualifier = '')
          role_refs = reading.role_sequence.all_role_ref.sort_by{|role_ref| role_ref.ordinal}
          lrr = role_refs[role_refs.size - 1]
          element(
            # element(rr.role.is_unique ? "one" : "some", :class=>:keyword) +
            reading.expand([], include_rolenames) do |rr, freq_con, l_adj, name, t_adj, role_name_def, literal|
              if role_name_def
                role_name_def = role_name_def.gsub(/\(as ([^)]+)\)/) {
                  span("(as #{ termref(rr.role.object_type.name, $1, rr.role.object_type) })", 'keyword')
                }
              end
              # qualify the last role of the reading
              quantifier = ''
              if rr == lrr
                uniq = true
                (0 ... role_refs.size - 2).each{|i| uniq = uniq && role_refs[i].role.is_unique }
                quantifier =  uniq ? "one" : "at least one"
              end
              role_ref(rr, quantifier, l_adj, name, t_adj, role_name_def, literal)
            end,
            {:class => 'reading'}
          )
        end

        def generate_table(composite)
          @tables_emitted[composite] = true
          delayed_indices = []

          table_defn =
          "                <h3 id=\"LDMD_#{table_name(composite)}\">#{composite.mapping.name}</h3>\n" +
          "                  <table class=\"table table-bordered table-striped\">\n" +
          "                    <thead style=\"background-color: #aaa;\">\n" +
          "                      <tr>\n" +
          "                        <th>Attribute</th><th>Data Type</th><th>Man</th><th>Description</th>\n" +
          "                      </tr>\n" +
          "                    </thead>\n" +
          "                    <tbody>\n" +
          (
            composite.mapping.all_leaf.flat_map do |leaf|
              # Absorbed empty subtypes appear as leaves
              next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

              generate_column leaf, 11
            end
          ).compact.flat_map{|f| "#{f}" }*"\n"+"\n" +
          "                    </tbody>\n" +
          "                  </table>\n"

          table_keys =
          (
            composite.all_index.map do |index|
              generate_index index, delayed_indices, 9
            end.compact.sort +
            composite.all_foreign_key_as_source_composite.map do |fk|
              # trace :ldm, "generate foreign key for #{fk.composite.mapping.name}"
              generate_foreign_key fk, 9
            end.compact.sort
          ).compact.flat_map{|f| "#{f}" }*"<br>\n"+"\n"

          table_values =
            if composite.mapping.object_type.all_instance.size > 0 then
              table_values =
              "                  <table class=\"table table-bordered table-striped\">\n" +
              "                    <thead style=\"background-color: #aaa;\">\n" +
              "                      <tr>\n" +
              (
                composite.mapping.all_leaf.flat_map do |leaf|
                  # Absorbed empty subtypes appear as leaves
                  next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)
                  column_name = safe_column_name(leaf)
                  "  " * 11 + "  <th>#{column_name}\n"
                end
              ) * "\n" + "\n" +
              "                      </tr>\n" +
              "                    </thead>\n" +
              "                    <tbody>\n" +
              "                    </tbody>\n" +
              "                  </table>\n"
            else
              ''
            end

          table_defn + table_keys + table_values
        end

        def generate_column leaf, indent
          column_name = safe_column_name(leaf)
          padding = " "*(column_name.size >= column_name_max ? 1 : column_name_max-column_name.size)
          constraints = leaf.all_leaf_constraint

          identity = ''

          "  " * indent + "<tr>\n" +
          "  " * indent + "  <td>#{column_name}\n" +
          "  " * indent + "  <td>#{component_type(leaf, column_name)}\n" +
          "  " * indent + "  <td>#{leaf.path_mandatory ? 'Yes' : 'No'}\n" +
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
          'boolean'
        end

        def surrogate_type
          'bigint'
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
            # }#{
            #   (component.path_mandatory ? '' : ' NOT') + ' NULL'
            # }#{
            #   # REVISIT: This is an SQL Server-ism. Replace with a standard SQL SEQUENCE/
            #   # Emit IDENTITY for columns auto-assigned on commit (except FKs)
            #   if a = object_type.is_auto_assigned and a != 'assert' and
            #       !component.all_foreign_key_field.detect{|fkf| fkf.foreign_key.source_composite == component.root}
            #     ' IDENTITY'
            #   else
            #     ''
            #   end
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
            when /^BOOLEAN$/
              'boolean'
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

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
      end
    end
    publish_generator Doc::LDM
  end
end
