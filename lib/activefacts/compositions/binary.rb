require "activefacts/compositions"

module ActiveFacts
  module Compositions
    class Binary < Compositor
      def generate
	super

	trace :binary_, "Constructing Binary Composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    mapping.re_rank
	  end
	end

	trace :binary_, "Full binary composition" do
	  @mappings.keys.sort_by(&:name).each do |object_type|
	    mapping = @mappings[object_type]
	    mapping.show_trace 
	  end
	end

      end
    end
  end
end
