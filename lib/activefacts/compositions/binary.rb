#
# ActiveFacts Compositions, Binary Compositor.
#
#	Fans of RDF will like this one.
#
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
      def generate
	super

	trace :binary_, "Constructing Binary Composition" do
	  @binary_mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @binary_mappings[object_type]
	    mapping.re_rank
	  end
	end

	trace :binary_, "Full binary composition" do
	  @binary_mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @binary_mappings[object_type]
	    mapping.show_trace 
	  end
	end

      end
    end
  end
end
