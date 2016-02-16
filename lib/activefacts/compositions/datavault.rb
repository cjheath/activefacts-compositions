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

      def devolve_all_satellites
	classify_composites

	# Delete all foreign keys to reference tables
	@reference_composites.each do |composite|
	  composite.all_foreign_key_as_target_composite.each(&:retract)
	end

	# For each hub and link, move each non-identifying member
	# to a new satellite or promote it to a new link.

	(@hub_composites + @link_composites).
	each do |composite|
	  devolve_satellites composite
	end

	rename_parents

	# REVISIT: Retracting these leaves some ForeignKeys with no Composite. It's mandatory, so this shouldn't be possible. Find out why
	# @reference_composites.each(&:retract)
      end

      # Create a new composite for each satellite, and move the relevant Components
      # across from the Composite Mapping. For each new satellite, inject a
      # load date-time and a reference to the surrogate on the hub or link,
      # and add an index over those two fields.
      def devolve_satellites composite
	trace :datavault?, "Detecting satellite fields for #{composite.inspect}" do
	  satellites = {}

	  # Find the members of this mapping that contain identifying leaves:
	  pi = composite.primary_index
	  ni = composite.natural_index
	  identifiers =
	    (Array(pi ? pi.all_index_field : nil) +
	     Array(ni ? ni.all_index_field : nil)).
	    map{|ixf| ixf.component.path[1]}.
	    uniq

	  composite.mapping.all_member.to_a.each do |member|
	    # If this member is in the natural or surrogate key, leave it there
	    next if identifiers.include?(member)

	    # Any member that is the absorption of a foreign key to a hub or link
	    # (which is all, since we removed FKs to reference tables)
	    # must be converted to a Mapping for a new Entity Type that notionally
	    # objectifies the absorbed fact type. This Mapping is a new link composite.
	    if member.is_a?(MM::Absorption) && member.foreign_key
	      lift_absorption_to_link member
	      next
	    end

	    # We may absorb a subtype that has no contents. There's no point moving these to a satellite.
	    next if is_empty_inheritance member

	    satellite_name = name_satellite member
	    satellite = satellites[satellite_name]
	    unless satellite
	      satellite =
	      satellites[satellite_name] =
		create_satellite satellite_name, composite
	    end

	    devolve_member_to_satellite satellite, member
	  end
	  satellites.each do |satellite_name, satellite|
	    trace :datavault, "REVISIT: Adding parent Keys to satellite #{satellite_name.inspect}"
	    # trace :datavault, "REVISIT: Include this Foreign Key with the load DateTime injection in a primary key"
	  end
	end
      end

      # Decide what to call a new satellite that will adopt this component
      def name_satellite component
	satellite_name =
	  if component.is_a?(MM::Absorption)
	    pc = component.parent_role.uniqueness_constraint and
	    pc.concept.all_concept_annotation.map{|ca| ca.mapping_annotation =~ /^satellite *(.*)/ && $1}.compact.uniq[0]
	  # REVISIT: How do we name the satellite for an Indicator? Add a Concept Annotation on the fact type?
	  end
	satellite_name = satellite_name.words.capcase if satellite_name
	satellite_name ||= component.root.mapping.name
	satellite_name += ' SAT'
      end

      # Create a new satellite for the same object_type as thos composite
      def create_satellite name, composite
	mapping = @constellation.Mapping(:new, name: name, object_type: composite.mapping.object_type)
	@constellation.Composite(mapping, composition: @composition)
      end

      # This component is being moved to a new composite, so any indexes that it or its
      # children contribute to, cannot now be used to search for the specified composite.
      def remove_indices component
	if component.is_a?(MM::Mapping)
	  component.all_member.each{|member| remove_indices member}
	end
	component.all_index_field.each do |ixf|
	  trace :datavault, "Removing #{ixf.access_path.inspect}" do
	    ixf.access_path.retract
	  end
	end
      end

      # Move this member from its current parent to the satellite
      def devolve_member_to_satellite satellite, member
	remove_indices member

	member.parent = satellite.mapping
	if member.is_a?(MM::Absorption) && member.foreign_key
	  trace :datavault, "Setting new source composite for #{member.foreign_key.inspect}"
	  member.foreign_key.source_composite = satellite
	end
	trace :datavault, "Satellite #{satellite.mapping.name.inspect} field #{member.inspect}"
      end

      # This absorption reflects a time-varying fact type, which becomes a new link:
      def lift_absorption_to_link absorption
	trace :datavault, "Promote #{absorption.inspect} to a new Link" do
	  link_name = absorption.root.mapping.name + absorption.child_role.name
	  mapping = @constellation.Mapping(:new, name: link_name, object_type: absorption.parent_role.object_type)
	  link = @constellation.Composite(mapping, composition: @composition)
	  absorption.parent = mapping

	  # REVISIT: Add a load DateTime value
	  # load_field = @constellation.Absorption

	  # Add a natural key:
	  natural_index =
	    @constellation.Index(:new, composite: link, is_unique: true,
	      presence_constraint: nil, composite_as_natural_index: link)
	  @constellation.IndexField(access_path: natural_index, ordinal: 0, component: absorption)
	  # REVISIT: @constellation.IndexField(access_path: natural_index, ordinal: 1, component: date_field)

	  # Add a surrogate key:
	  inject_surrogate link

	  devolve_satellites link
	  @link_composites << link
	end
      end

      def rename_parents
	@link_composites.each do |composite|
	  composite.mapping.name += " LINK"
	end
	@hub_composites.each do |composite|
	  composite.mapping.name += " HUB"
	end
	@reference_composites.each do |composite|
	  composite.mapping.name += " REF"
	end
      end

      def classify_composites
	trace :datavault, "Classify relational tables into reference, hub and link tables" do
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
		  !@reference_composites.include?(fk.composite) and
		    # Are all foreign key fields in the natural index?
		    !fk.all_foreign_key_field.detect{|fkf| !natural_index_components.include?(fkf.component)}
		end
	      fk_target_names = fks_enclosed_by_pk.map{|fk| fk.composite.mapping.name}
	      trace :datavault, "Natural index for #{composite.mapping.name} encloses foreign keys to #{fk_target_names*', '}"
	      fks_enclosed_by_pk.size > 1
	    end
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
