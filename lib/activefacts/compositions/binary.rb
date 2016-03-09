### Composition
# ActiveFacts Compositions, Binary Compositor.
#
#       Fans of RDF will like this one.
#
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
      def self.options
        {}
      end

      def generate
        super

        trace :binary!, "Constructing Binary Composition" do
          @binary_mappings.keys.sort_by(&:name).each do |object_type|
            mapping = @binary_mappings[object_type]
            mapping.re_rank
            composite = @constellation.Composite(mapping, composition: @composition)
          end
        end

        trace :binary!, "Full binary composition" do
          @binary_mappings.keys.sort_by(&:name).each do |object_type|
            mapping = @binary_mappings[object_type]
            mapping.show_trace 
          end
        end

      end
    end
    publish_compositor(Binary)
  end
end
