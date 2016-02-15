#
# ActiveFacts Compositions, DataVault Compositor.
#
#	Computes a Data Vault schema.
#
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions/relational"

module ActiveFacts
  module Compositions
    class DataVault < Relational
    public
      def self.options
	{
	  reference: ['Boolean', "Emit the reference (static) tables as well. Default is to omit them"]
	}
      end

      def initialize constellation, name, options = {}
	# Extract recognised options:
	@option_reference = options.delete('reference')
	@option_surrogates = true   # Always inject surrogates
	super constellation, name, options
      end

      def composite_is_reference composite
	object_type = composite.mapping.object_type
	object_type.concept.all_concept_annotation.detect{|ca| ca.mapping_annotation == 'static'} or
	  !object_type.is_a?(ActiveFacts::Metamodel::EntityType)
      end

      # Data Vaults need a surrogate key on every Hub and Link.
      # Don't add a surrogate on a Reference table!
      def needs_surrogate(composite)
	!composite_is_reference(composite) and
	  super
      end

      def devolve_satellites
	classify_composites

	# Now, for each hub and link, figure out how many satellites are needed,
	# create a new composite for each satellite, and move the relevant Components
	# across from the Composite Mapping. For each new satellite, inject a
	# load date-time and a reference to the surrogate on the hub or link,
	# and add an index over those two fields.
      end

      def classify_composites
	initial_composites = @composition.all_composite.to_a
	@reference_composites, non_reference_composites =
	  initial_composites.partition { |composite| composite_is_reference(composite) }

	@link_composites, @hub_composites = non_reference_composites.partition do |composite|
	  # It's a Link if the natural index includes more than one foreign key.
	  # Note that at this stage, foreign key target fields are not populated, but source fields are.
	  trace :datavault, "Decide whether #{composite.mapping.name} is a link or a hub" do
	    natural_index_components = composite.natural_index.all_index_field.map(&:component)
	    fks_enclosed_by_pk =
	      composite.all_foreign_key_as_source_composite.select do |fk|
		# All foreign key fields must be in the natural index
		!fk.all_foreign_key_field.detect{|fkf| !natural_index_components.include?(fkf.component)}
	      end
	    fk_target_names = fks_enclosed_by_pk.map{|fk| fk.composite.mapping.name}
	    trace :datavault, "Natural index for #{composite.mapping.name} encloses foreign keys to #{fk_target_names*', '}"
	    fks_enclosed_by_pk.size > 1
	  end
	end

	trace :datavault!, "Data Vault classification of composites:" do
	  trace :datavault, "Reference: #{@reference_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
	  trace :datavault, "Hub: #{@hub_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
	  trace :datavault, "Link: #{@link_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
	end
      end

    end

    publish_compositor(DataVault)
  end
end
