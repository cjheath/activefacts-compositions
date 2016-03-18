#
#       ActiveFacts GraphViz generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generator'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore 
    module Doc
      class Graph
        def self.options
          {
          }
        end

        def initialize composition, options = {}
          @composition = composition
          @options = options
        end

        def generate
          composites = @composition.all_composite.sort_by{|c| c.mapping.name }
          header +
          tables(composites) + "\n" +
          # All-equal ranks causes graphviz to shit itself
          # ranks(composites) +
          fks(composites) +
          footer
        end

        def header
          <<-END
digraph G {
  fontname = Helvetica;
  outputmode = "nodesfirst";
  XXratio = 1.4;      // pad when done to this aspect ratio (portrait)
  rankdir = LR;               // Requires extra { } in record labels

  // You might like neato's layout better than fdp's:
  // layout = neato;          // neato, dot, sfdp, circo
  // mode = KK;

  graph[
    layout = fdp;     // neato, dot, sfdp, circo
    overlap = false;  // scalexy, compress
    splines = ortho;  // ortho, compound, curved
    packmode = "graph";       // node, clust, graph, array_c4. Turns on pack=true
    mclimit = 3.0;
    sep = 0.2;                // Treat nodes as though they were 1.2 times what they actually are
    // nodesep = 0.6; // in dot, it's inches. others, who knows?
  ];

  node[
    shape=record,
    width=.1,
    height=.1
  ];
END
        end

        def footer
          "}\n"
        end

        def tables composites
          composites.map.with_index(1) do |composite, i|
            "t#{i}[shape=record, label=\"{#{
              named_stack(
                text(composite.mapping.name),
                [columns(
                  stack(composite.mapping.leaves.map{''}),
                  stack(composite.mapping.leaves.map.with_index(1){|l, i| tagged_text("c#{i}:e", l.column_name.capcase)})
                )]
              )
            }}\", style=rounded]"
          end.map{|t| "  #{t};\n"}*''
        end

        def ranks composites
          "  { rank = same; #{(1..composites.size).map{|i| "t#{i}".inspect+'; '}*'' }}\n"
        end

        def fks composites
          composites.flat_map.with_index(1) do |composite, cnum|
            composite.all_foreign_key_as_source_composite.map do |fk|
              target_num = composites.index(fk.composite)+1
              fkc = fk.all_foreign_key_field[0].component
              mandatory = fkc.path_mandatory
              source_col_num = composite.mapping.leaves.index(fkc)+1
              "t#{target_num}:name:e -> t#{cnum}:c#{source_col_num}:w[arrowhead=invempty#{mandatory ? 'tee' : ''}; arrowsize=2;]"
              # Also, arrowtail. small circle is 
              # splineType=...
            end
          end.map{|f| "  #{f};\n"}*''
        end

        def stack items
          "{#{items*'|'}}"
        end

        def columns *a
          stack a
        end

        def named_stack head, items
          "{<name>#{head}|{#{stack items}}}"
        end

        def tagged_text tag, txt
          "<#{tag}> "+text(txt)
        end

        def text t
          t.gsub(/[ |<>]/){|c| "\\#{c}"}
        end

        MM = ActiveFacts::Metamodel
      end

    end
    publish_generator Doc::Graph
  end
end

