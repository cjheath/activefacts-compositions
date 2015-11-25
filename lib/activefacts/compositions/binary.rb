require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
      def generate
	super

	trace :binary, "Constructing Binary Composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    mapping.re_rank
	  end
	end

	trace :composition, "Full binary composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    mapping.show_trace 
	  end
	end

      end
    end
  end
end
