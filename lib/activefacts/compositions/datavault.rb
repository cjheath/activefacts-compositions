#
# ActiveFacts Compositions, DataVault Compositor.
#
#       Computes a Data Vault schema.
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
          reference: ['Boolean', "Emit the reference (static) tables as well. Default is to omit them"],
          datestamp: ['String', "Use this data type for date stamps"]
        }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        @option_reference = options.delete('reference')
        @option_datestamp = options.delete('datestamp')

        super constellation, name, options

        @option_surrogates = true   # Always inject surrogates regardless of superclass
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
      def devolve_satellites composite, lift_links = true
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
            if lift_links && member.is_a?(MM::Absorption) && member.foreign_key
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
          composite.mapping.re_rank
          satellites.each do |satellite_name, satellite|
            trace :datavault, "Adding parent key and load time to satellite #{satellite_name.inspect}" do

              # Add a Surrogate foreign Key to the parent composite
              fk_target = composite.primary_index.all_index_field.single
              fk_field =
                @constellation.Injection(
                  :new,
                  parent: satellite.mapping,
                  name: fk_target.component.name,
                  object_type: surrogate_type
                )

              # Add a load DateTime value
              date_field = @constellation.Injection(
                :new,
                parent: satellite.mapping,
                name: "Load"+datestamp_type_name,
                object_type: datestamp_type
              )

              # Add a natural key:
              natural_index =
                @constellation.Index(:new, composite: satellite, is_unique: true,
                  presence_constraint: nil, composite_as_natural_index: satellite)
              @constellation.IndexField(access_path: natural_index, ordinal: 0, component: fk_field)
              @constellation.IndexField(access_path: natural_index, ordinal: 1, component: date_field)

              # REVISIT: re-ranking members without a preferred_identifier does not rank the PK fields in order.
              satellite.mapping.re_rank

              # Add a foreign key to the hub
              fk = @constellation.ForeignKey(
                  :new,
                  source_composite: satellite,
                  composite: composite,
                  absorption: nil           # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
                )
              @constellation.ForeignKeyField(foreign_key: fk, ordinal: 0, component: fk_field)
              # REVISIT: This should be filled in by complete_foreign_keys, but it has no Absorption
              @constellation.IndexField(access_path: fk, ordinal: 0, component: fk_target.component)

            end
          end
        end
      end

      def datestamp_type_name
        @datestamp_type_name ||= begin
          [true, '', 'true', 'yes', nil].include?(t = @option_datestamp) ? 'DateTime' : t
        end
      end

      def datestamp_type
        @datestamp_type ||= begin
          vocabulary = @composition.all_composite.to_a[0].mapping.object_type.vocabulary
          @constellation.ValueType(
            vocabulary: vocabulary,
            name: datestamp_type_name,
            concept: [:new, :implication_rule => "datestamp injection"]
          )
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

      # This absorption reflects a time-varying fact type that involves another Hub, which becomes a new link:
      def lift_absorption_to_link absorption
        trace :datavault, "Promote #{absorption.inspect} to a new Link" do
          link_name = absorption.root.mapping.name + absorption.child_role.name

          link_from = absorption.parent.composite
          link_to = absorption.foreign_key.composite

          # A new composition that maps the same object type as this absorption's parent:
          mapping = @constellation.Mapping(:new, name: link_name, object_type: absorption.parent_role.object_type)
          link = @constellation.Composite(mapping, composition: @composition)

          # Move the absorption across to here
          absorption.parent = mapping

          if absorption.is_a?(MM::Absorption) && absorption.foreign_key
            trace :datavault, "Setting new source composite for #{absorption.foreign_key.inspect}"
            absorption.foreign_key.source_composite = link
          end

          # Add a Surrogate foreign Key to the link_from composite
          fk1_target = link_from.primary_index.all_index_field.single
          # debugger
          fk1_field =
            @constellation.SurrogateKey(
              :new,
              parent: mapping,
              name: fk1_target.component.name,
              object_type: fk1_target.component.object_type
            )

          # Add a Surrogate foreign Key to the link_to composite
          fk2_target = link_to.primary_index.all_index_field.single
          fk2_field =
            @constellation.SurrogateKey(
              :new,
              parent: mapping,
              name: fk2_target.component.name,
              object_type: fk2_target.component.object_type
            )

          # Add a natural key:
          natural_index =
            @constellation.Index(:new, composite: link, is_unique: true,
              presence_constraint: nil, composite_as_natural_index: link)
          @constellation.IndexField(access_path: natural_index, ordinal: 0, component: fk1_field)
          @constellation.IndexField(access_path: natural_index, ordinal: 1, component: fk2_field)

          # Add ForeignKeys
          fk1 = @constellation.ForeignKey(
              :new,
              source_composite: link,
              composite: link_from,
              absorption: nil       # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
            )
          @constellation.ForeignKeyField(foreign_key: fk1, ordinal: 0, component: fk1_field)
          # REVISIT: This should be filled in by complete_foreign_keys, but it has no Absorption
          @constellation.IndexField(access_path: fk1, ordinal: 0, component: fk1_target.component)
          fk2 = @constellation.ForeignKey(
              :new,
              source_composite: link,
              composite: link_to,
              absorption: nil       # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
            )
          @constellation.ForeignKeyField(foreign_key: fk2, ordinal: 0, component: fk2_field)
          # REVISIT: This should be filled in by complete_foreign_keys, but it has no Absorption
          @constellation.IndexField(access_path: fk2, ordinal: 0, component: fk2_target.component)

=begin
          issues = 0
          link.validate do |object, problem|
            $stderr.puts "#{object.inspect}: #{problem}"
            issues += 1
          end
          debugger if issues > 0
=end

          # Add a load DateTime value
          date_field = @constellation.Injection(:new,
            parent: mapping,
            name: "FirstLoad"+datestamp_type_name,
            object_type: datestamp_type
          )
          mapping.re_rank

          # Add a surrogate key:
          inject_surrogate link, ' LINKID'

          # devolve_satellites link, false
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
              trace :datavault, "Natural index for #{composite.mapping.name} encloses foreign keys to #{fk_target_names*', '}" if fks_enclosed_by_pk.size > 0
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
