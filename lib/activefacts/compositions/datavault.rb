#
# ActiveFacts Compositions, DataVault Compositor.
#
#       Computes a Data Vault schema.
#
# Copyright (c) 2015 Clifford Heath. Read the LICENSE file.
#
require "activefacts/compositions/relational"
require "activefacts/compositions/traits/datavault"

module ActiveFacts
  module Compositions
    class DataVault < Relational
      extend Traits::DataVault
      include Traits::DataVault

      BDV_ANNOTATIONS = /same as link|hierarchy link|computed link|exploration link|computed satellite|point in time|bridge/
      BDV_LINK_ANNOTATIONS = /same as link|hierarchy link|computed link|exploration link/
      BDV_SAT_ANNOTATIONS = /computed satellite/
      BDV_PIT_ANNOTATIONS = /point in time/
      BDV_BRIDGE_ANNOTATIONS = /bridge/

    public
      def self.options
        datavault_options.
        merge({
          reference: ['Boolean', "Emit the reference (static) tables as well. Default is to omit them"],
          id: ['String', "Append this to data vault surrogate keys (default HID)"],
          hubname: ['String', "Suffix or pattern for naming hub tables. Include a + to insert the name. Default 'HUB'"],
          linkname: ['String', "Suffix or pattern for naming link tables. Include a + to insert the name. Default 'LINK'"],
          satname: ['String', "Suffix or pattern for naming satellite tables. Include a + to insert the name. Default 'SAT'"],
          pitname: ['String', "Suffix or pattern for naming point in time tables. Include a + to insert the name. Default 'PIT'"],
          bridgename: ['String', "Suffix or pattern for naming bridge tables. Include a + to insert the name. Default 'BRIDGE'"],
          refname: ['String', "Suffix or pattern for naming reference tables. Include a + to insert the name. Default '+'"],
        }).
        merge(Relational.options).
        reject{|k,v| [:surrogates].include?(k) }  # Datavault surrogates are not optional
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        datavault_initialize options
        @option_reference = options.delete('reference')
        @option_id = ' ' + (options.delete('id') || 'HID')
        @option_hub_name = options.delete('hubname') || 'HUB'
        @option_hub_name.sub!(/^/,'+ ') unless @option_hub_name =~ /\+/
        @option_link_name = options.delete('linkname') || 'LINK'
        @option_link_name.sub!(/^/,'+ ') unless @option_link_name =~ /\+/
        @option_sat_name = options.delete('satname') || 'SAT'
        @option_sat_name.sub!(/^/,'+ ') unless @option_sat_name =~ /\+/
        @option_pit_name = options.delete('refname') || 'PIT'
        @option_pit_name.sub!(/^/,'+ ') unless @option_ref_name =~ /\+/
        @option_bridge_name = options.delete('refname') || 'BRIDGE'
        @option_bridge_name.sub!(/^/,'+ ') unless @option_ref_name =~ /\+/
        @option_ref_name = options.delete('refname') || 'REF'
        @option_ref_name.sub!(/^/,'+ ') unless @option_ref_name =~ /\+/

        super constellation, name, options, 'DataVault'

        @option_surrogates = true   # Always inject surrogates regardless of superclass
      end

      # We need to find links that need surrogate keys before we inject the surrogates
      def inject_surrogates
        classify_composites

        super
      end

      def composite_is_reference composite
        object_type = composite.mapping.object_type
        all_ca = object_type.concept.all_concept_annotation

        all_ca.detect{|ca| ca.mapping_annotation == 'static'} or
          !object_type.is_a?(ActiveFacts::Metamodel::EntityType)
      end

      def composite_is_bdv composite
        object_type = composite.mapping.object_type
        all_ca = object_type.concept.all_concept_annotation

        trace :datavault, "composite #{composite.mapping.name} annotations #{all_ca.map{|ca| ca.mapping_annotation} *' '}"
        all_ca.detect{|ca| ca.mapping_annotation =~ BDV_ANNOTATIONS}
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

      def classify_composites
        detect_reference_tables

        @bdv_composites, @rdv_composites =
          @non_reference_composites.partition { |composite| composite_is_bdv(composite) }

        trace :datavault, "Classify non-reference composites into hubs, links, pits and bridges" do
          # Make an initial determination, then adjust for foreign keys to links afterwards
          @hub_composites = []
          @link_composites = []
          @sat_composites = []
          @bdv_link_composites = []
          @bdv_sat_composites = []
          @pit_composites = []
          @bridge_composites = []
          @key_structure = {}
          @links_as_hubs = {}
          @pit_hub = {}
          @pit_members = {}
          @pit_satellite = {}

          rdv_classify_composites
          bdv_classify_composites

          trace :datavault_classification!, "Data Vault classification of composites:" do
            trace :datavault, "Reference: #{@reference_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "Raw: #{@rdv_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "Business: #{@bdv_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "Hub: #{@hub_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "Link: #{@link_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "BDV Link: #{@bdv_link_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "BDV Sat: #{@bdv_sat_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "PIT: #{@pit_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
            trace :datavault, "Bridge: #{@bridge_composites.map(&:mapping).map(&:object_type).map(&:name)*', '}"
          end
        end
      end

      def bdv_classify_composites
        # Classify the business links and bridges
        @bdv_composites.sort_by{|c| c.mapping.name}.each do |composite|
          trace :datavault, "Decide whether #{composite.mapping.name} is a link or bridge"
          object_type = composite.mapping.object_type
          composite.composite_group = 'bdv'
          mapped_to = object_type.fact_type.all_role.to_a
          trace :datavault, "#{composite.mapping.name} encloses foreign keys to #{mapped_to.inspect}" unless mapped_to.compact.empty?

          all_ca = composite.mapping.object_type.concept.all_concept_annotation
          if all_ca.detect{ |ca| ca.mapping_annotation =~ BDV_LINK_ANNOTATIONS}
            @bdv_link_composites << composite
          elsif all_ca.detect{ |ca| ca.mapping_annotation =~ BDV_BRIDGE_ANNOTATIONS}
            @bridge_composites << composite
          end
        end

        # Classify the point in time tables
        @rdv_composites.sort_by{|c| c.mapping.name}.each do |composite|
          composite.composite_group = 'rdv'
          trace :datavault, "Decide whether #{composite.mapping.name} has point in time table"

          pit_members = composite.mapping.all_member.select do |member|
            if member.is_a?(MM::Absorption)
              if found_pit = check_pit(member)
                trace :datavault, "Found PIT member #{member.child_role.object_type.name}"
              end
              found_pit
            else
              false
            end
          end

          if pit_members.size > 0
            pit_composite = create_pit(composite.mapping.name, composite)
            @pit_composites << pit_composite
            @pit_hub[pit_composite] = composite
            @pit_members[pit_composite] = pit_members
          end
        end
      end

      def check_pit component
        all_pc = component.parent_role.all_role_ref.map(&:role_sequence).uniq.flat_map(&:all_presence_constraint).uniq
        all_pc.detect do |pc|
          pc.concept.all_concept_annotation.detect{ |ca| ca.mapping_annotation =~ BDV_PIT_ANNOTATIONS}
        end
      end

      # Create a new PIT for the same object_type as this composite
      def create_pit name, composite
        mapping = @constellation.Mapping(:new, name: name, object_type: composite.mapping.object_type)
        @constellation.Composite(mapping, composition: @composition, composite_group: 'bdv')
      end

      def rdv_classify_composites
        @link_composites, @hub_composites =
          @rdv_composites.
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

        trace :datavault, "Checking for foreign keys that reference links" do
          # Links may never be the target of a foreign key.
          # Any such links must be defined as hubs instead.

          fk_dependencies_by_target = {}
          fk_dependencies_by_source = {}
          (@hub_composites+@link_composites).each do |composite|
            target_composites = enumerate_foreign_keys composite.mapping
            target_composites.each do |target_composite|
              next if @reference_composites.include?(target_composite)
              (fk_dependencies_by_target[target_composite] ||= []) << composite
              (fk_dependencies_by_source[composite] ||= []) << target_composite
            end
          end

          fk_dependencies_by_target.keys.each do |target_composite|
            if @link_composites.delete(target_composite)
              trace :datavault, "Link #{target_composite.inspect} must be a hub because foreign keys reference it"
              @hub_composites << target_composite
              @links_as_hubs[target_composite] = true
            end
          end

          begin
            converted =
              @link_composites.select do |composite|
                targets = fk_dependencies_by_source[composite]
                id_targets = composite_key_structure(composite).compact
                next if targets.size == id_targets.size
                trace :datavault, "Link #{composite.mapping.name} must be a hub because it has non-identifying FK references"
                @link_composites.delete(composite)
                @hub_composites << composite
                @links_as_hubs[composite] = true
              end
          end while converted.size > 0

          # Note: We may still have hubs whose identifiers contain foreign keys to one or more other hubs.
          # REVISIT: These foreign keys will be deleted so these hubs stand alone,
          # but have been re-instated as new links to the referenced hubs.
        end
      end

      def detect_reference_tables
        initial_composites = @composition.all_composite.to_a
        @reference_composites, @non_reference_composites =
          initial_composites.partition { |composite| composite_is_reference(composite) }
      end

      def composite_key_structure composite
        # We know that composite.mapping.object_type is an EntityType because all ValueType composites are reference tables
        object_type = composite.mapping.object_type

        mapped_to =
          object_type.preferred_identifier.role_sequence.all_role_ref_in_order.map do |role_ref|
            player = role_ref.role.object_type
            next nil if player == object_type && role_ref.role.fact_type.all_role.size == 1 # Unaries.
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

      def apply_schema_transformations
        delete_reference_table_foreign_keys

        # For each hub and link, move each non-identifying member
        # to a new satellite or promote it to a new link.
        (@hub_composites + @link_composites).each do |composite|
          devolve composite
        end

        # Rename parents for rdv and bdv
        apply_composite_name_pattern

        # inject datetime and record source for rdv hubs and links
        inject_all_datetime_recordsource

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

        # Devolve point in time tables, if any
        @pit_composites.each do |composite|
          devolve_pit(composite)
        end

      end

      def devolve_pit(pit_composite)
        # inject standard PIT components: surrogate key, hub hash key and snapshot date time
        inject_surrogate(pit_composite)

        hub_composite = @pit_hub[pit_composite]
        hub_hash_field = hub_composite.primary_index.all_index_field.single.component
        pit_hub_field = hub_hash_field.fork_to_new_parent(pit_composite.mapping)
        date_field = @constellation.ValidFrom(:new,
          parent: pit_composite.mapping,
          name: "Snapshot "+datestamp_type_name,
          object_type: datestamp_type,
          injection_annotation: "datavault"
        )

        natural_index =
          @constellation.Index(:new, composite: pit_composite, is_unique: true,
            presence_constraint: nil, composite_as_natural_index: pit_composite #, composite_as_primary_index: pit_composite
            )
        @constellation.IndexField(access_path: natural_index, ordinal: 0, component: pit_hub_field)
        @constellation.IndexField(access_path: natural_index, ordinal: 1, component: date_field)

        # Add a foreign key to the hub
        fk = @constellation.ForeignKey(
            :new,
            source_composite: pit_composite,
            composite: hub_composite,
            absorption: nil           # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
          )
        @constellation.ForeignKeyField(foreign_key: fk, ordinal: 0, component: pit_hub_field)
        # This should be filled in by complete_foreign_keys, but there is no Absorption
        @constellation.IndexField(access_path: fk, ordinal: 0, component: hub_hash_field)

        # inject hash and load date time for sats associated with all pit members
        pit_members = @pit_members[pit_composite]
        sat_composites = pit_members.map{|pm| @pit_satellite[pm]}.compact.uniq

        sat_composites.each do |sat_composite|
          sat_name = sat_composite.mapping.name
          sat_hash_name = "#{sat_name}#{@option_id}"

          src_hash_field = hub_hash_field.fork_to_new_parent(pit_composite.mapping)
          src_hash_field.name = sat_hash_name
          src_load_field = @constellation.ValidFrom(:new,
            parent: pit_composite.mapping,
            name: "#{sat_name} Load "+datestamp_type_name,
            object_type: datestamp_type,
            injection_annotation: "datavault"
          )

          sat_index_fields = sat_composite.primary_index.all_index_field.to_a
          sat_hash_field = sat_index_fields[0].component
          sat_load_field = sat_index_fields[1].component

          # Add a foreign key to the satellite's primary key and load date time
          fk = @constellation.ForeignKey(
              :new,
              source_composite: pit_composite,
              composite: sat_composite,
              absorption: nil           # REVISIT: This is a ForeignKey without its mandatory Absorption. That's gonna hurt
            )
          @constellation.ForeignKeyField(foreign_key: fk, ordinal: 0, component: src_hash_field)
          @constellation.IndexField(access_path: fk, ordinal: 0, component: sat_hash_field)
          @constellation.ForeignKeyField(foreign_key: fk, ordinal: 1, component: src_load_field)
          @constellation.IndexField(access_path: fk, ordinal: 1, component: sat_load_field)
        end
        pit_composite.mapping.re_rank
      end

      def delete_reference_table_foreign_keys
        trace :datavault, "Delete foreign keys to reference tables" do
          # Delete all foreign keys to reference tables
          @reference_composites.each do |composite|
            composite.all_foreign_key_as_target_composite.each(&:retract)
          end
        end
      end

      def prefer_natural_key building_natural_key, source_composite, target_composite
        return false if building_natural_key && (@link_composites.include?(source_composite) || @bdv_link_composites.include?(source_composite))
        building_natural_key && @hub_composites.include?(target_composite)
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
          is_link = @link_composites.include?(composite) || @links_as_hubs.include?(composite)
          composite.mapping.all_member.to_a.each do |member|

            # Any member that is the absorption of a foreign key to a hub or link
            # (which is all, since we removed FKs to reference tables)
            # must be converted to a Mapping for a new Entity Type that notionally
            # objectifies the absorbed fact type. This Mapping is a new link composite.
            if devolve_links && member.is_a?(MM::Absorption) && member.foreign_key
              next if is_link
              devolve_absorption_to_link member, identifiers.include?(member)
              next
            end

            # If this member is in the natural or surrogate key, leave it there
            # REVISIT: But if it is an FK to another hub, devolve it to a link as well.
            next if identifiers.include?(member)

            # We may absorb a subtype that has no contents. There's no point moving these to a satellite.
            next if is_empty_inheritance member

            satellite_name, is_computed = *name_satellite(member)
            if !(satellite = satellites[satellite_name])
              satellite = satellites[satellite_name] = create_satellite(satellite_name, composite)
              satellite.composite_group = (is_computed ? 'bdv' : 'rdv')
              if member.is_a?(MM::Absorption) && check_pit(member)
                @pit_satellite[member] = satellite
              end
            end

            devolve_member_to_satellite satellite, member
          end
          composite.mapping.re_rank

          if @hub_composites.include?(composite)
            # Links-as-hubs have foreign keys over natural indexes; these must be deleted.
            composite.all_foreign_key_as_source_composite.to_a.each(&:retract)
          end

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
          fk_field = fk_target.component.fork_to_new_parent satellite.mapping

          # Add a load DateTime value and record source
          date_field = inject_datetime_recordsource(satellite.mapping)

          # Add a primary and natural key:
          natural_index =
            @constellation.Index(:new, composite: satellite, is_unique: true,
              presence_constraint: nil, composite_as_natural_index: satellite, composite_as_primary_index: satellite)
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

          if satellite.composite_group == 'bdv'
            @bdv_sat_composites << satellite
          else
            @sat_composites << satellite
          end
        end
      end

      # Decide what to call a new satellite that will adopt this component
      def satellite_base_name_and_type component
        computed_name = nil
        satellite_name =
          if component.is_a?(MM::Absorption)
            pc = component.parent_role.base_role.uniqueness_constraint and
            pc.concept.all_concept_annotation.map do |ca|
              computed_name = ca.mapping_annotation =~ /^computed satellite *(.*)/ && "#{$1} Computed"
              ca.mapping_annotation =~ /^satellite *(.*)/ && $1 or computed_name
            end.compact.uniq[0]
          # REVISIT: How do we name the satellite for an Indicator? Add a Concept Annotation on the fact type?
          end
        satellite_name = satellite_name.words.capcase if satellite_name
        [ satellite_name || component.root.mapping.name, computed_name ]
      end

      def name_satellite component
        name, is_computed = *satellite_base_name_and_type(component)
        [apply_name(@option_sat_name, name), is_computed != nil]
      end

      # Create a new satellite for the same object_type as this composite
      def create_satellite name, composite
        mapping = @constellation.Mapping(:new, name: name, object_type: composite.mapping.object_type)
        @constellation.Composite(mapping, composition: @composition)
      end

      # This component is being moved to a new composite, so any indexes that it or its
      # children contribute to, cannot now be used to search for the specified composite.
      # A component being moved to a satellite or a hub cannot keep its indices.
      def remove_indices component
        component.all_index_field.map(&:access_path).uniq.each(&:retract)
        component.all_member.each{|member| remove_indices member}
      end

      def change_all_fk_source component, source_composite
        if component.is_a?(MM::Absorption) && component.foreign_key
          trace :datavault, "Setting new source composite for #{component.foreign_key.inspect}"
          component.foreign_key.source_composite = source_composite
        end

        component.all_member.each do |member|
          change_all_fk_source member, source_composite
        end
      end

      # Move this member from its current parent to the satellite
      def devolve_member_to_satellite satellite, member
        remove_indices member

        member.parent = satellite.mapping
        change_all_fk_source member, satellite
        trace :datavault, "Satellite #{satellite.mapping.name.inspect} field #{member.inspect}"
      end

      # This absorption reflects a time-varying fact type that involves another Hub, which becomes a new link.
      # REVISIT: "make_copy" says that the original field must remain, because it's in its parent's natural key.
      def devolve_absorption_to_link absorption, make_copy
        trace :datavault, "Promote #{absorption.inspect} to a new Link" do

          # REVISIT: Here we need a new objectified fact type with the same two players and the same readings,
          # complete with LinkFactTypes. Then we need two Absorptions, one for each LinkFactType, and with
          # the same child role names as the role names in our original fact type.
          #
          # The current code tries to re-use the same fact type, but the absorptions cannot work for both as
          # the parent object type can only be one of the two types. That's why this is currently failing its
          # validation tests.

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
            remove_indices absorption

            # Move the absorption across to here
            absorption.parent = mapping

            if absorption.foreign_key
              trace :datavault, "Setting new source composite for #{absorption.foreign_key.inspect}"
              absorption.foreign_key.source_composite = link
              debugger unless absorption.foreign_key.all_foreign_key_field.single
              fk2_component = absorption.foreign_key.all_foreign_key_field.single.component
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
          fk1_component = fk1_target.component.fork_to_new_parent mapping

          fk2_target = link_to.primary_index.all_index_field.single
          if make_copy
            # See the above comment for fk1_component; it applies here also
            fk2_component = fk2_target.component.fork_to_new_parent mapping
          else
            # We're using the leaf component of the absorption we moved across
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
            absorption.foreign_key.retract
          end

=begin
          issues = 0
          link.validate do |object, problem|
            $stderr.puts "#{object.inspect}: #{problem}"
            issues += 1
          end
          debugger if issues > 0
=end


          # # Add a load DateTime value
          # date_field = add_datetime_recordsource(mapping)

          #link.mapping.re_rank

          # devolve link, false
          @link_composites << link
        end
      end

      def apply_name pattern, name
        pattern.sub(/\+/, name)
      end

      def apply_composite_name_pattern
        @reference_composites.each do |composite|
          composite.mapping.name = apply_name(@option_ref_name, composite.mapping.name)
        end
        @hub_composites.each do |composite|
          composite.mapping.name = apply_name(@option_hub_name, composite.mapping.name)
        end
        @link_composites.each do |composite|
          composite.mapping.name = apply_name(@option_link_name, composite.mapping.name)
        end
        @bdv_link_composites.each do |composite|
          composite.mapping.name = apply_name(@option_link_name, composite.mapping.name)
        end
        @pit_composites.each do |composite|
          composite.mapping.name = apply_name(@option_pit_name, composite.mapping.name)
        end
        @bridge_composites.each do |composite|
          composite.mapping.name = apply_name(@option_bridge_name, composite.mapping.name)
        end
      end

      def inject_all_datetime_recordsource
        @link_composites.each do |composite|
          inject_datetime_recordsource(composite.mapping)
        end
        @hub_composites.each do |composite|
          inject_datetime_recordsource(composite.mapping)
        end
      end

    end

    publish_compositor(DataVault)
  end
end
