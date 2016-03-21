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
          datestamp: ['String', "Use this data type for date stamps"],
          id: ['String', "Append this to data vault surrogate keys (default VID)"],
          hubname: ['String', "Suffix or pattern for naming hub tables. Include a + to insert the name. Default 'HUB'"],
          linkname: ['String', "Suffix or pattern for naming link tables. Include a + to insert the name. Default 'LINK'"],
          satname: ['String', "Suffix or pattern for naming satellite tables. Include a + to insert the name. Default 'SAT'"],
          refname: ['String', "Suffix or pattern for naming reference tables. Include a + to insert the name. Default '+'"],
        }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        @option_reference = options.delete('reference')
        @option_datestamp = options.delete('datestamp')
        @option_id = ' ' + (options.delete('id') || 'VID')
        @option_hub_name = options.delete('hubname') || 'HUB'
        @option_hub_name.sub!(/^/,'+ ') unless @option_hub_name =~ /\+/
        @option_link_name = options.delete('linkname') || 'LINK'
        @option_link_name.sub!(/^/,'+ ') unless @option_link_name =~ /\+/
        @option_sat_name = options.delete('satname') || 'SAT'
        @option_sat_name.sub!(/^/,'+ ') unless @option_sat_name =~ /\+/
        @option_ref_name = options.delete('refname') || 'SAT'
        @option_ref_name.sub!(/^/,'+ ') unless @option_ref_name =~ /\+/

        super constellation, name, options

        @option_surrogates = true   # Always inject surrogates regardless of superclass
      end

      # We need to find links that need surrogate keys before we inject the surrogates
      def inject_surrogates
        classify_composites

        super
      end

      def composite_is_reference composite
        object_type = composite.mapping.object_type
        object_type.concept.all_concept_annotation.detect{|ca| ca.mapping_annotation == 'static'} or
          !object_type.is_a?(ActiveFacts::Metamodel::EntityType)
      end

      # Data Vaults need a surrogate key on every Hub and Link.
      # Don't add a surrogate on a Reference table!
      def needs_surrogate(composite)
        return false if composite_is_reference(composite)

        # REVISIT: The following is debatable. If the natural primary key is an ok surrogate, should we inject another?
        return true if @non_reference_composites.include?(composite)

        super
      end

      # Change the default extension from our superclass':
      def inject_surrogate composite, extension = @option_id
        super
      end

      def devolve_all
        delete_reference_table_foreign_keys

        # For each hub and link, move each non-identifying member
        # to a new satellite or promote it to a new link.

        @non_reference_composites.
        each do |composite|
          devolve composite
        end

        rename_parents

        unless @option_reference
          if trace :reference_retraction
            # Add a logger so we can trace the resultant retractions:
            @constellation.loggers << proc do |*args|
              trace :reference_retraction, args.inspect
            end
          end

          @reference_composites.each do |rc|
            trace :reference_retraction, "Retracting #{rc.inspect}" do
              rc.retract
            end
          end
          @reference_composites = []

          @constellation.loggers.pop if trace :reference_retraction
        end
      end

      def detect_reference_tables
        initial_composites = @composition.all_composite.to_a
        @reference_composites, @non_reference_composites =
          initial_composites.partition { |composite| composite_is_reference(composite) }
      end

      def delete_reference_table_foreign_keys
        trace :datavault, "Delete foreign keys to reference tables" do
          # Delete all foreign keys to reference tables
          @reference_composites.each do |composite|
            composite.all_foreign_key_as_target_composite.each(&:retract)
          end
        end
      end

      def classify_composites
        detect_reference_tables

        trace :datavault, "Classify remaining tables into hub and link tables" do
          # Make an initial determination, then adjust for references to links afterwards
          @key_structure = {}
          @link_composites, @hub_composites =
            @non_reference_composites.
            sort_by{|c| c.mapping.name}.
            partition do |composite|
              trace :datavault, "Decide whether #{composite.mapping.name} is a link or a hub" do
                @key_structure[composite] =
                  mapped_to =
                  composite_key_structure composite

                # It's a Link if the preferred identifier includes more than non_reference_composite.
                mapped_to.compact.size > 1
              end
            end

          # This leaves us with links and hubs whose key structure references other links.
          # Each link that is the target of such a foreign key must become a hub.
          (@hub_composites+@link_composites).each do |composite|
            mapped_to = @key_structure[composite]
            to_links = mapped_to.compact.select{|to| @link_composites.include?(to)}
            if to_links.size > 0
              trace :datavault_classify, "Hub/Link #{composite.mapping.name} IS TO LINK(S) #{to_links.inspect} (and #{mapped_to.size-to_links.size} parts)"
              to_links.uniq.each do |composite|
                @link_composites.delete(composite)
                @hub_composites << composite
              end
            end
          end

          # Note: We may still have hubs whose identifiers contain foreign keys to one or more other hubs.
          # REVISIT: These foreign keys will be deleted so these hubs stand alone,
          # but have been re-instated as new links to the referenced hubs.
        end

        trace :datavault!, "Data Vault classification of composites:" do
          trace :datavault, "Reference: #{@reference_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
          trace :datavault, "Hub: #{@hub_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
          trace :datavault, "Link: #{@link_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
        end
      end

      def composite_key_structure composite
        # We know that composite.mapping.object_type is an EntityType because all ValueType composites are reference tables

        mapped_to =
          composite.mapping.object_type.preferred_identifier.role_sequence.all_role_ref_in_order.map do |role_ref|
            player = role_ref.role.object_type
            candidate = @candidates[player]
            next nil unless candidate
            # Take care of full absorption
            while candidate.full_absorption
              candidate = candidate.full_absorption.composition
            end
            @non_reference_composites.include?(c = candidate.mapping.composite) ? c : nil
          end

        trace :datavault, "Preferred identifier for #{composite.mapping.name} encloses foreign keys to #{mapped_to.inspect}" unless mapped_to.compact.empty?

        number_of_keys = mapped_to.compact.size
        number_of_values = mapped_to.size-number_of_keys
        trace :datavault_classify,
          if number_of_keys > 1
            # Links have more than one FK to a hub in their key
            "Link #{composite.mapping.name} links #{mapped_to.compact.inspect} with #{number_of_values} values"
          elsif number_of_keys == 1 && number_of_values > 0
            # This is a new hub with a composite key - but we will have to eliminate the foreign key to the base hub
            "Augmented Hub #{composite.mapping.name} has a hub link to #{mapped_to.compact[0].inspect} and #{number_of_values} values"
          elsif number_of_keys == 1
            # This is a new hub with a single-part key that references another hub.
            "Dependent Hub #{composite.mapping.name} is identified by another hub: #{mapped_to.compact[0].inspect}"
          else
            "Hub #{composite.mapping.name} has #{mapped_to.size} parts in its key"
          end

        mapped_to
      end

      # For each member of this composite, decide whether to devolve it to a satellite
      # or to a new link. If it goes to a link that's still part of this natural key,
      # we need to leave that key intact, but remove the foreign key it entails.
      #
      # New links and satellites get new fields for the load date-time and a
      # references to the surrogate(s) on the hub or link, and add an index over
      # those two fields.
      def devolve composite, devolve_links = true
        trace :datavault?, "Devolving non-identifying fields for #{composite.inspect}" do
          # Find the members of this mapping that contain identifying leaves:
          pi = composite.primary_index
          ni = composite.natural_index
          identifiers =
            (Array(pi ? pi.all_index_field : nil) +
             Array(ni ? ni.all_index_field : nil)).
            map{|ixf| ixf.component.path[1]}.
            uniq

          satellites = {}
          composite.mapping.all_member.to_a.each do |member|

            # Any member that is the absorption of a foreign key to a hub or link
            # (which is all, since we removed FKs to reference tables)
            # must be converted to a Mapping for a new Entity Type that notionally
            # objectifies the absorbed fact type. This Mapping is a new link composite.
            if devolve_links && member.is_a?(MM::Absorption) && member.foreign_key
              devolve_absorption_to_link member, identifiers.include?(member)
              next
            end

            # If this member is in the natural or surrogate key, leave it there
            # REVISIT: But if it is an FK to another hub, devolve it to a link as well.
            next if identifiers.include?(member)

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

          # Add the audit and identity fields for the satellite:
          satellites.values.each do |satellite|
            audit_satellite composite, satellite
          end
        end
      end

      # Add the audit and foreign key fields to a satellite for this composite
      def audit_satellite composite, satellite
        trace :datavault, "Adding parent key and load time to satellite #{satellite.mapping.name.inspect}" do

          # Add a Surrogate foreign Key to the parent composite
          fk_target = composite.primary_index.all_index_field.single
          fk_field = fork_component_to_new_parent(satellite.mapping, fk_target.component)

          # Add a load DateTime value
          date_field = @constellation.ValidFrom(
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
          # This should be filled in by complete_foreign_keys, but there is no Absorption
          @constellation.IndexField(access_path: fk, ordinal: 0, component: fk_target.component)

          satellite.classify_constraints
          satellite.all_local_constraint.map(&:local_constraint).each(&:retract)
          leaf_constraints = satellite.mapping.all_leaf.flat_map(&:all_leaf_constraint).map(&:leaf_constraint).each(&:retract)
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
          @constellation.ObjectType[[[vocabulary.name], datestamp_type_name]] or
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
            pc = component.parent_role.base_role.uniqueness_constraint and
            pc.concept.all_concept_annotation.map{|ca| ca.mapping_annotation =~ /^satellite *(.*)/ && $1}.compact.uniq[0]
          # REVISIT: How do we name the satellite for an Indicator? Add a Concept Annotation on the fact type?
          end
        satellite_name = satellite_name.words.capcase if satellite_name
        satellite_name ||= component.root.mapping.name
        satellite_name = apply_name(@option_sat_name, satellite_name)
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

      # This absorption reflects a time-varying fact type that involves another Hub, which becomes a new link.
      # REVISIT: "make_copy" says that the original field must remain, because it's in its parent's natural key.
      def devolve_absorption_to_link absorption, make_copy
        trace :datavault, "Promote #{absorption.inspect} to a new Link" do

          #
          # REVISIT: Here we need a new objectified fact type with the same two players and the same readings,
          # complete with LinkFactTypes. Then we need two Absorptions, one for each LinkFactType, and with
          # the same child role names as the role names in our original fact type.
          #
          # The current code tries to re-use the same fact type, but the absorptions cannot work for both as
          # the parent object type can only be one of the two types. That's why this is currently failing its
          # validation tests.
          #

          link_name =
            absorption.
            parent_role.
            fact_type.
            reading_preferably_starting_with_role(absorption.parent_role).
            expand([], false).words.capwords*' '
          # A simpler naming, not using the fact type reading
          # link_name = absorption.root.mapping.name + ' ' + absorption.child_role.name

          link_from = absorption.parent.composite
          link_to = absorption.foreign_key.composite

          # A new composition that maps the same object type as this absorption's parent:
          mapping = @constellation.Mapping(:new, name: link_name, object_type: absorption.parent_role.object_type)
          link = @constellation.Composite(mapping, composition: @composition)

          unless make_copy
            # Move the absorption across to here
            absorption.parent = mapping

            if absorption.is_a?(MM::Absorption) && absorption.foreign_key
              trace :datavault, "Setting new source composite for #{absorption.foreign_key.inspect}"
              absorption.foreign_key.source_composite = link
            end
          end

          # Add a surrogate key:
          inject_surrogate link

          # Add a Surrogate foreign Key to the link_from composite
          fk1_target = link_from.primary_index.all_index_field.single
          raise "Internal error: #{link_from.inspect} should have a surrogate key" unless fk1_target
          # Here, we're jumping directly to the foreign key field.
          # Normally we'd have the Absorption of the object type, containing the FK field.
          # We have no fact type for this absorption; it should be the LinkFactType of the notional objectification
          # This affects the absorption path comment on the related SQL coliumn, for example.
          # REVISIT: Add the LinkFactType for the notional objectification, and use that.
          fk1_component = fork_component_to_new_parent(mapping, fk1_target.component)

          fk2_target = link_to.primary_index.all_index_field.single
          if make_copy
            # See the above comment for fk1_component; it aplies here also
            fk2_component = fork_component_to_new_parent(mapping, fk2_target.component)
          else
            # We're using the component we moved across
            fk2_component = absorption.foreign_key.all_foreign_key_field.single.component
            # Add a Surrogate foreign Key to the link_to composite
          end

          # Add a natural key:
          natural_index =
            @constellation.Index(:new, composite: link, is_unique: true,
              presence_constraint: nil, composite_as_natural_index: link)
          @constellation.IndexField(access_path: natural_index, ordinal: 0, component: fk1_component)
          @constellation.IndexField(access_path: natural_index, ordinal: 1, component: fk2_component)

          # Add ForeignKeys
          fk1 = @constellation.ForeignKey(
              :new,
              source_composite: link,
              composite: link_from,
              absorption: nil       # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
            )
          @constellation.ForeignKeyField(foreign_key: fk1, ordinal: 0, component: fk1_component)
          # REVISIT: This should be filled in by complete_foreign_keys, but it has no Absorption
          @constellation.IndexField(access_path: fk1, ordinal: 0, component: fk1_target.component)

          if make_copy
            fk2 = @constellation.ForeignKey(
                :new,
                source_composite: link,
                composite: link_to,
                absorption: nil       # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
              )
            @constellation.ForeignKeyField(foreign_key: fk2, ordinal: 0, component: fk2_component)
            # REVISIT: This should be filled in by complete_foreign_keys, but it has no Absorption
            @constellation.IndexField(access_path: fk2, ordinal: 0, component: fk2_target.component)
          end

=begin
          issues = 0
          link.validate do |object, problem|
            $stderr.puts "#{object.inspect}: #{problem}"
            issues += 1
          end
          debugger if issues > 0
=end

          # Add a load DateTime value
          date_field = @constellation.ValidFrom(:new,
            parent: mapping,
            name: "FirstLoad"+datestamp_type_name,
            object_type: datestamp_type
          )
          mapping.re_rank

          #link.mapping.re_rank

          # devolve link, false
          @link_composites << link
        end
      end

      def apply_name pattern, name
        pattern.sub(/\+/, name)
      end

      def rename_parents
        @link_composites.each do |composite|
          composite.mapping.name = apply_name(@option_link_name, composite.mapping.name)
        end
        @hub_composites.each do |composite|
          composite.mapping.name = apply_name(@option_hub_name, composite.mapping.name)
        end
        @reference_composites.each do |composite|
          composite.mapping.name = apply_name(@option_ref_name, composite.mapping.name)
        end
      end

    end

    publish_compositor(DataVault)
  end
end
