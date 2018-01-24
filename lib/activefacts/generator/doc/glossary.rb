#
#       ActiveFacts Generators.
#
#       Generate a glossary in HTML
#
# Copyright (c) 2009 Clifford Heath. Read the LICENSE file.
#
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'

module ActiveFacts
  module Generators #:nodoc:
    module Doc
      class Glossary #:nodoc:
        # Options are comma or space separated:
        # * gen_bootstrap Generate bootstrap styled glossary html
        def self.options
          {
            gen_bootstrap: ['Boolean', "Generate bootstrap styled glossary html"],
          }
        end
        
        # Base class for generators of object-oriented class libraries for an ActiveFacts vocabulary.
        def initialize vocabulary, options = {}
          @vocabulary = vocabulary  # REVISIT: This should be a Composition here
          @options = options
          @gen_bootstrap = options.has_key?("gen_bootstrap")
        end

        def puts(*a)
          @out.puts *a
        end

        def print(*a)
          @out.print *a
        end

        def generate
          @all_object_type =
            @vocabulary.
              all_object_type.
              sort_by{|o| o.name.gsub(/ /,'').downcase}
          
          glossary_start +
          glossary_body +
          glossary_end
        end

        def glossary_start
          if !@gen_bootstrap
            # puts "<link rel='stylesheet' href='css/orm2.css' media='screen' type='text/css'/>"
            css_file = "css/orm2.css"
          
                  File.open(File.dirname(__FILE__)+css_file) do |f|
                    "<style media='screen' type='text/css'>\n" +
                    f.read +
                    %Q{
                      .glossary-facttype, .glossary-constraints { display: block; }\n
                      .glossary-doc.hide-alternates .glossary-alternates { display: none; }\n
                      .glossary-doc.hide-constraints .glossary-constraints { display: none; }\n
                      .glossary-doc.hide-examples .glossary-example { display: none; }\n
                    }.gsub(/^\s+/, '') +
                    "</style>\n"
                  end +

                  %Q{
                    <style media='print' type='text/css'>\n
                    .keyword { color: #0000CC; font-style: italic; display: inline; }\n
                    .vocabulary, .object_type { color: #8A0092; font-weight: bold; }\n
                    .copula { color: #0E5400; }\n
                    .value { color: #FF990E; display: inline; }\n
                    .glossary-toc { display: none; }\n
                    .glossary-facttype, .glossary-reading { display: inline; }\n
                    </style>\n
                  }.gsub(/^\s+/, '')
          else
            ''
          end
        end

        def glossary_body
          if @gen_bootstrap
            object_types_dump_toc()
            object_types_dump_def()
          else
            object_types_dump_def()
            object_types_dump_toc()
          end
        end
        
        def glossary_end
          if !@gen_bootstrap
                  %Q{
                  <script type="text/javascript">
                  function toggle_class(e, c) {
                    if (!e) return;
                    var n = e.className;
                    var i = n.indexOf(c);
                    if (i == -1) {
                      e.className = n+' '+c;
                    } else {
                      e.className = n.slice(0, i)+n.slice(i+c.length);
                    }
                    if (document.location.toString().indexOf('#') >= 0)
                      document.location = document.location; // Re-scroll to the current fragment
                  }
                  function toggle_constraints() {
                    toggle_class(document.getElementById('glossary-doc'), 'hide-constraints');
                  }
                  function toggle_alternates() {
                    toggle_class(document.getElementById('glossary-doc'), 'hide-alternates');
                  }
                  function toggle_examples() {
                    toggle_class(document.getElementById('glossary-doc'), 'hide-examples');
                  }
                  </script>
                  }.gsub(/^\s+/, '')
          else
            ''
          end
        end

        def object_types_dump_toc
          if @gen_bootstrap
            '<div class="col-md-3 glossary-sidebar">' + "\n"
          else
            '<div class="glossary-sidebar">' + "\n"
          end +
          '<h1 style="visibility: hidden">X</h1>' +"\n" +
          '<ol class="glossary-toc">' + "\n"
          @all_object_type.
                  reject do |o|
                    o.name == '_ImplicitBooleanValueType' or
                    o.kind_of?(ActiveFacts::Metamodel::ValueType) && o.all_role.size == 0 or
                    o.kind_of?(ActiveFacts::Metamodel::TypeInheritance)
                  end.
                    map do |o|
                      "<li>#{termref(o.name)}</li>"
                    end *"\n" + "\n" +
          %Q{
            </ol>
            <div class="glossary-controls">
            <input type="button" onclick="toggle_constraints()" value="Constraints" class="glossary-toggle-constraint">
            <input type="button" onclick="toggle_alternates()" value="Alternates" class="glossary-toggle-alternates">
            <input type="button" onclick="toggle_examples()" value="Examples" class="glossary-toggle-examples">
            </div>
            </div>
          }
        end
        
        def object_types_dump_def
          if @gen_bootstrap
            '<div class="col-md-5 glossary-doc hide-alternates hide-constraints" id="glossary-doc">' + "\n"
          else
            '<div class="glossary-doc hide-alternates hide-constraints" id="glossary-doc">' + "\n"
          end +
          '<h1>#{@vocabulary.name}</h1>' + "\n" +
          "<dl>\n" +
          @all_object_type.
            map do |o|
              case o
              when ActiveFacts::Metamodel::TypeInheritance
                nil
              when ActiveFacts::Metamodel::ValueType
                value_type_dump(o)
              else
                if o.fact_type
                  objectified_fact_type_dump(o)
                else
                  entity_type_dump(o)
                end
              end
          end +
          "</dl>\n" +
          "</div>\n"
        end

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

        def dl(text, klass = nil)
          element(text, klass ? {:class => klass} : {}, 'dl')
        end

        # A definition of a term
        def termdef(name)
          element(name, {:name => name, :class => 'object_type'}, 'a')
        end

        # A reference to a defined term (excluding role adjectives)
        def termref(name, role_name = nil)
          role_name ||= name
          element(role_name, {:href=>'#'+name, :class=>:object_type}, 'a')
        end

        # Text that should appear as part of a term (including role adjectives)
        def term(name)
          element(name, :class=>:object_type)
        end

        def value_type_dump(o, include_alternate = true, include_facts = true, include_constraints = true)
          return '' if o.all_role.size == 0 or  # Skip value types that are only used as supertypes
            o.name == '_ImplicitBooleanValueType'
   
          defn_term =
            '  <dt>' +
            "#{termdef(o.name)} " +
            (if o.supertype
              span('is written as ', :keyword) + termref(o.supertype.name)
            else
              " (a fundamental data type)"
            end) +
            "</dt>\n"

          defn_detail =
            "  <dd>\n" +
              value_sub_types(o) +
              relevant_facts_and_constraints(o, include_alternate, include_facts, include_constraints) +
              (include_facts ? values(o) : '') +
            "  </dd>\n"
          
          defn_term + defn_detail
        end

        def value_sub_types(o)
          o.
            all_value_type_as_supertype.    # All value types for which o is a supertype
            sort_by{|sub| sub.name}.
            map do |sub|
              div(
                "#{termref(sub.name)} #{span('is written as', 'keyword')} #{termref(o.name)}",
                'glossary-facttype'
              )
            end * "\n" + "\n"
        end

        def values(o)
          o.all_instance.
          sort_by{|i|
            [i.population.name, i.value.literal]
          }.
          map do |i|
            v = i.value
            div(
                (i.population.name.empty? ? '' : i.population.name+': ') +
                termref(o.name) + ' ' +
                div(
                # v.is_literal_string ? v.literal.inspect : v.literal,
                  v.literal.inspect,
                  'value'
                ),
                'glossary-example'
              )
          end * "\n" + "\n"
        end

        def relevant_facts_and_constraints(o, include_alternate = true, include_facts = true, include_constraints = true)
            o.
              all_role.
              map{|r| r.fact_type}.
              uniq.
              reject do |ft| ft.is_a?(ActiveFacts::Metamodel::LinkFactType) end.
              map { |ft| [ft, "    #{fact_type_with_constraints(ft, include_alternate, o, include_constraints)}"] }.
              sort_by{|ft, text| [ ft.is_a?(ActiveFacts::Metamodel::TypeInheritance) ? 0 : 1, text]}.
              map{|ft, text| text} * "\n"
        end

        def role_ref(rr, freq_con, l_adj, name, t_adj, role_name_def, literal)
          term_parts = [l_adj, termref(name), t_adj].compact
          [
            freq_con ? element(freq_con, :class=>:keyword) : nil,
            term_parts.size > 1 ? term([l_adj, termref(name), t_adj].compact*' ') : term_parts[0],
            role_name_def,
            literal
          ]
        end

        def expand_reading(reading, include_rolenames = true)
          element(
            reading.expand([], include_rolenames) do |rr, freq_con, l_adj, name, t_adj, role_name_def, literal|
              if role_name_def
                role_name_def = role_name_def.gsub(/\(as ([^)]+)\)/) {
                  span("(as #{ termref(rr.role.object_type.name, $1) })", 'keyword')
                }
              end
              role_ref rr, freq_con, l_adj, name, t_adj, role_name_def, literal
            end,
            {:class => 'copula'}
          )
        end

        def fact_type_block(ft, include_alternates = true, wrt = nil, include_rolenames = true)
          div(fact_type(ft, include_alternates, wrt, include_rolenames), 'glossary-facttype')
        end

        def fact_type(ft, include_alternates = true, wrt = nil, include_rolenames = true)
          role = ft.all_role.detect{|r| r.object_type == wrt}
          preferred_reading = ft.reading_preferably_starting_with_role(role)
          alternate_readings = ft.all_reading.reject{|r| r == preferred_reading}

          div(
            expand_reading(preferred_reading, include_rolenames),
            'glossary-reading'
          )+
          (if include_alternates and alternate_readings.size > 0
            div(
              "(alternatively: " +
              alternate_readings.map do |reading|
                div(
                  expand_reading(reading, include_rolenames),
                  'glossary-reading'
                )
              end * ",\n" + ')',
              'glossary-alternates'
            )
          else
            ''
          end
          )
        end

        def fact_type_with_constraints(ft, include_alternates = true, wrt = nil, include_constraints = true)
          if ft.entity_type
            div(
              div(termref(ft.entity_type.name) + span(' is where ', 'keyword')) +
              div(fact_type(ft, include_alternates, wrt)),
              'glossary-objectification'
            )
          else
            fact_type_block(ft, include_alternates, wrt)
          end +
          if include_constraints then
            %Q{\n<ul class="glossary-constraints">\n} +
            (unless ft.is_a?(ActiveFacts::Metamodel::TypeInheritance)
              fact_type_constraints(ft)
            else
              ''
            end) +
            "</ul>"
          else
            ""
          end
        end

        def fact_type_constraints(ft)
          ft.internal_presence_constraints.map do |pc|
            residual_role = ft.all_role.detect{|r| !pc.role_sequence.all_role_ref.detect{|rr| rr.role == r}}
            next '' unless residual_role
            reading = ft.all_reading.detect{|reading|
                reading.role_sequence.all_role_ref_in_order[reading.role_numbers[-1]].role == residual_role
              }
            next '' unless reading
              div(
                element(
                  reading.expand_with_final_presence_constraint { |*a| role_ref(*a) },
                  {:class => 'copula'}
                ),
                'glossary-constraint'
              ) + "\n"
              end.compact * ''
        end

        def objectified_fact_type_dump(o, include_alternate = true, include_facts = true, include_constraints = true)
          defn_term =
            "  <dt>" +
              "#{termdef(o.name)}" +
              # " (#{span('in which', 'keyword')} #{fact_type(o.fact_type, false, nil, nil)})" +
              "</dt>\n"
          # REVISIT: Handle separate identification

          defn_detail =
            "  <dd>\n" +
            fact_type_with_constraints(o.fact_type, include_alternate, nil, include_constraints) + "\n" +

            o.fact_type.all_role_in_order.map do |r|
              n = r.object_type.name
              div("#{termref(o.name)} involves #{span('one', 'keyword')} #{termref(r.role_name || n, n)}", "glossary-facttype")
            end * "\n" + "\n" +
            relevant_facts_and_constraints(o, include_alternate, include_facts, include_constraints) + "\n" +
            "  </dd>"

            defn_term + defn_detail
        end

        def entity_type_dump(o, include_alternate = true, include_facts = true, include_constraints = true)
          pi = o.preferred_identifier
          supers = o.supertypes
          if (supers.size > 0) # Ignore identification by a supertype:
            pi = nil if pi && pi.role_sequence.all_role_ref.detect{|rr| rr.role.fact_type.is_a?(ActiveFacts::Metamodel::TypeInheritance) }
          end

          defn_term =
            "  <dt>" +
            "#{termdef(o.name)} " +
            "</dt>\n"

          defn_detail =
            "  <dd>" +
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
            relevant_facts_and_constraints(o, include_alternate, include_facts, include_constraints) +
            (include_facts ? entities(o) : '') +
            "  </dd>\n"
          
          defn_term + defn_detail
        end

        def entities(o)
          return '' if o.preferred_identifier.role_sequence.all_role_ref.size > 1 # REVISIT: Composite identification
          o.all_instance.map do |i|
            v = i.value
            ii = i    # The identifying instance

            until v
              pi = ii.object_type.preferred_identifier            # ii is an Entity Type
              break if pi.role_sequence.all_role_ref.size > 1     # REVISIT: Composite identification

              identifying_fact_type = pi.role_sequence.all_role_ref.single.role.fact_type
              # Find the role played by this instance through which it is identified:
              irv = i.all_role_value.detect{|rv| rv.fact.fact_type == identifying_fact_type }
              # Get the other RoleValue in what must be a binary fact type:
              orv = irv.fact.all_role_value.detect{|rv| rv != irv}
              ii = orv.instance
              v = ii.value    # Does this instance have a value? If so, we're done.
            end

            next unless v
            div(
              (i.population.name.empty? ? '' : i.population.name+': ') +
              termref(o.name) + ' ' +
              div(
                  # v.is_literal_string ? v.literal.inspect : v.literal,
                  v.literal.inspect,
                  'value'
              ),
              'glossary-example'
            )
          end * "\n" + "\n"
        end
      end
    end
  end
end

