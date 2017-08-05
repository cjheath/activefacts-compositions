#
# ActiveFacts Compositions, DocGraph Compositor.
#
#       Computes an Document/Semantic Graph schema.
#
# Copyright (c) 2017 Factil Pty Ltd. Read the LICENSE file.
#
require "activefacts/compositions"

module ActiveFacts
  module Metamodel
    class Composite
      def is_document
        @isa_document = true
      end
      
      def is_document?
        @isa_document
      end
      
      def is_triple
        @isa_triple = true
      end
      
      def is_triple?
        @isa_triple
      end
    end
  end
end

module ActiveFacts
  module Compositions
    class DocGraph < Compositor
      MM = ActiveFacts::Metamodel unless const_defined?(:MM)
      TRIPLE_ANNOTATION = /triple/

      def self.options
        {
          surrogates: ['Boolean', "Inject a surrogate key into each table whose primary key is not already suitable as a foreign key"],
          source: ['Boolean', "Generate composition for source schema"],
          target: ['Boolean', "Generate composition for target schema"],
          transform: ['Boolean', "Generate composition for transform schema"]
        }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        @option_surrogates = options.delete('surrogates')
        super constellation, name, options
      end

      def generate
        super

        trace :docgraph_details!, "Generating docgraph composition" do
          # Make a data structure to help in computing the documents
          make_candidates

          # Apply any obvious document/graph factors
          assign_default_docgraph
          
          # Figure out how best to absorb things to reduce the number of documents
          optimise_absorption

          # Actually make a Composite object for each document and triple:
          make_composites

          # If a value type has been mapped to a document, add a property to hold its value
          inject_value_fields

          # # Inject surrogate keys if the options ask for that
          # inject_surrogates if @option_surrogates

          # # Remove the un-used absorption paths
          # delete_reverse_absorptions

          # Traverse the absorbed objects to build the path to each required property, including foreign keys:
          absorb_all_properties

          # Remove mappings for objects we have absorbed
          clean_unused_mappings
        end

        trace :docgraph!, "Full #{self.class.basename} composition" do
          @document_composites.values.sort_by{|composite| composite.mapping.name}.each do |composite|
            composite.show_trace
          end
          @triple_composites.values.sort_by{|composite| composite.mapping.name}.each do |composite|
            composite.show_trace
          end
        end
      end

      def make_candidates
        @candidates = @binary_mappings.inject({}) do |hash, (absorption, mapping)|
          hash[mapping.object_type] = Candidate.new(self, mapping)
          hash
        end
      end

      def assign_default_docgraph
        trace :docgraph_defaults!, "Preparing DocGraph composition by setting default assumptions" do
          @candidates.each do |object_type, candidate|
            candidate.assign_default(@composition)
          end
        end
      end

      def optimise_absorption
        trace :docgraph_optimiser!, "Optimise DocGraph Composition" do
          undecided = @candidates.keys.select{|object_type| @candidates[object_type].is_tentative}
          pass = 0
          finalised = []
          begin
            pass += 1
            trace :docgraph_optimiser, "Starting optimisation pass #{pass}" do
              finalised = optimise_absorption_pass(undecided)
            end
            trace :docgraph_optimiser, "Finalised #{finalised.size} on this pass: #{finalised.map{|f| f.name}*', '}"
            undecided -= finalised
          end while !finalised.empty?
        end
      end

      def optimise_absorption_pass undecided
        undecided.select do |object_type|
          candidate = @candidates[object_type]
          trace :docgraph_optimiser, "Considering possible status of #{object_type.name}" do

            # Rule 1: Always absorb an objectified unary into its role player (unless its forced to be separate)
            if !object_type.is_separate && (f = object_type.fact_type) && f.all_role.size == 1
              absorbing_ref = candidate.mapping.all_member.detect{|a| a.is_a?(MM::Absorption) and a.child_role.base_role == f.all_role.single}
              raise "REVISIT: Internal error" unless absorbing_ref.parent_role.object_type == object_type
              absorbing_ref = absorbing_ref.flip!
              candidate.full_absorption =
                @constellation.FullAbsorption(composition: @composition, absorption: absorbing_ref, object_type: object_type)
              trace :docgraph_optimiser, "Fully absorb objectified unary #{object_type.name} into #{f.all_role.single.object_type.name}"
              candidate.definitely_not_document
              next object_type
            end

            # # Rule 2: If the preferred_identifier contains one role only, played by an entity type that can absorb us, do that:
            # # (Leave pi_roles intact for further use below)
            # absorbing_ref = nil
            pi_roles = []
            # if object_type.is_a?(MM::EntityType) and              # We're an entity type
            #   pi_roles = object_type.preferred_identifier_roles and     # Our PI
            #   pi_roles.size == 1 and                                    # has one role
            #   single_pi_role = pi_roles[0] and                          # that role is
            #   single_pi_role.object_type.is_a?(MM::EntityType) and      # played by another Entity Type
            #   absorbing_ref =
            #     candidate.mapping.all_member.detect do |absorption|
            #       absorption.is_a?(MM::Absorption) && absorption.child_role.base_role == single_pi_role
            #     end
            #
            #   absorbing_ref = absorbing_ref.forward_absorption || absorbing_ref.flip!
            #   candidate.full_absorption =
            #     @constellation.FullAbsorption(composition: @composition, absorption: absorbing_ref, object_type: object_type)
            #   trace :docgraph_optimiser, "EntityType #{single_pi_role.object_type.name} identifies EntityType #{object_type.name}, so fully absorb it via #{absorbing_ref.inspect}"
            #   candidate.definitely_not_document
            #   next object_type
            # end

            # Rule 3: If there's more than one absorption path and any functional dependencies that can't absorb us, it's a document
            trace :docgraph_optimiser, "From-references for #{object_type.name}(#{pi_roles.map(&:object_type).map(&:name)*', '}) are #{candidate.references_from.map(&:inspect)*', '}"
            non_identifying_refs_from =
              candidate.references_from.reject do |member|
                case member
                when MM::Absorption
                  pi_roles.include?(member.child_role.base_role)
                when MM::Indicator
                  pi_roles.include?(member.role)
                else
                  false
                end
              end
            trace :docgraph_optimiser, "#{object_type.name} has #{non_identifying_refs_from.size} non-identifying functional roles" do
              non_identifying_refs_from.each do |a|
                trace :docgraph_optimiser, a.inspect
              end
            end

            trace :docgraph_optimiser, "#{object_type.name} has #{candidate.references_to.size} references to it" do
              candidate.references_to.each do |a|
                trace :docgraph_optimiser, a.inspect
              end
            end
            
            # Both of these conditions are not relevant for documents
            # if candidate.references_to.size > 1 and       # More than one place wants us
            #     non_identifying_refs_from.size > 0        # And we carry dependent values so cannot be absorbed
            #   trace :docgraph_optimiser, "#{object_type.name} has #{non_identifying_refs_from.size} non-identifying functional dependencies and #{candidate.references_to.size} absorption paths so it is a document"
            #   candidate.definitely_document
            #   next object_type
            # end

            # At this point, this object either has no functional dependencies or only one place it would be absorbed
            next false if !candidate.is_document   # We can't reduce the number of tables by absorbing this one

            absorption_paths =
              ( non_identifying_refs_from +   # But we should exclude any that are already involved in an absorption; pre-decided ET=>ET or supertype absorption!
                candidate.references_to       # These are our reverse absorptions that could absorb us
              ).select do |a|
                next false unless a.is_a?(MM::Absorption)   # Skip Indicators, we can't be absorbed there
                child_candidate = @candidates[a.child_role.object_type]

                # It's ok if we absorbed them already
                next true if a.full_absorption && child_candidate.full_absorption.absorption != a

                # If our counterpart is a full absorption, don't try to reverse that!
                next false if (aa = (a.forward_absorption || a.reverse_absorption)) && aa.full_absorption

                # Otherwise the other end must already be a document or fully absorbed into one
                next false unless child_candidate.nil? || child_candidate.is_document || child_candidate.full_absorption

                next false unless a.child_role.is_unique && a.parent_role.is_unique   # Must be one-to-one

                # next true if pi_roles.size == 1 && pi_roles.include?(a.parent_role) # Allow the sole identifying role for this object
                next false unless a.parent_role.is_mandatory # Don't absorb an object along a non-mandatory role
                true
              end

            trace :docgraph_optimiser, "#{object_type.name} has #{absorption_paths.size} absorption paths"

            # # Rule 4: If this object can be fully absorbed along non-identifying roles, do that (maybe flip some absorptions)
            # if absorption_paths.size > 0
            #   trace :docgraph_optimiser, "#{object_type.name} is fully absorbed in #{absorption_paths.size} places" do
            #     absorption_paths.each do |a|
            #       a = a.flip! if a.forward_absorption
            #       trace :docgraph_optimiser, "#{object_type.name} is fully absorbed via #{a.inspect}"
            #     end
            #   end
            #
            #   candidate.definitely_not_document
            #   next object_type
            # end

            # Rule 5: If this object has no functional dependencies (only its identifier), it can be absorbed in multiple places
            # We don't create FullAbsorptions, because they're only used to resolve references to this object; and there are none here
            refs_to = candidate.references_to.reject{|a|a.parent_role.base_role.is_identifying}
            if !refs_to.empty? and non_identifying_refs_from.size == 0
              refs_to.map! do |a|
                a = a.flip! if a.reverse_absorption   # We were forward, but the other end must be
                a.forward_absorption
              end
              trace :docgraph_optimiser, "#{object_type.name} is fully absorbed in #{refs_to.size} places: #{refs_to.map{|ref| ref.inspect}*", "}"
              candidate.definitely_not_document
              next object_type
            end

            false   # Otherwise we failed to make a decision about this object type
          end
        end
      end

      def top component
        component.parent ? top(component.parent) : component
      end
      
      # Remove the unused reverse absorptions:
      def delete_reverse_absorptions
        # @binary_mappings.each do |object_type, mapping|
        #   mapping.all_member.to_a.              # Avoid problems with deletion from all_member
        #   each do |member|
        #     next unless member.is_a?(MM::Absorption)
        #     next unless member.forward_absorption
        #     # retract if this absorption is not in a document or the forward absorption is in a document
        #     member.retract if @document_composites[top(member.forward_absorption).object_type] || !@document_composites[top(member).object_type]
        #   end
        #   mapping.re_rank
        # end
      end

      # After all document/triple decisions are made, convert Mappings for triples into Composites and retract the rest:
      def make_composites
        @document_composites = {}
        @triple_composites = {}
        @candidates.keys.to_a.each do |object_type|
          candidate = @candidates[object_type]

          if (candidate.is_document or candidate.is_triple) and !candidate.is_tentative
            make_composite(candidate)
          else
            @candidates.delete(object_type)
          end
        end
      end

      def make_composite candidate
        mapping = candidate.mapping
        composite = @constellation.Composite(mapping, composition: @composition)
        if candidate.is_document
          @document_composites[mapping.object_type] = composite
          composite.is_document
        else
          @triple_composites[mapping.object_type] = composite
          composite.is_triple
        end
      end

      # Inject a ValueField for each value type that is a document:
      def inject_value_fields
        @document_composites.each do |key, composite|
          mapping = composite.mapping
          if mapping.object_type.is_a?(MM::ValueType) and               # Composite needs a ValueField
              !mapping.all_member.detect{|m| m.is_a?(MM::ValueField)}   # And don't already have one
            trace :docgraph_properties, "Adding value field for #{mapping.object_type.name}"
            @constellation.ValueField(
              :new,
              parent: mapping,
              name: mapping.object_type.name+" Value",
              object_type: mapping.object_type
            )
            mapping.re_rank
          end
        end
      end

      def clean_unused_mappings
        @candidates.keys.to_a.each do |object_type|
          candidate = @candidates[object_type]
          next if candidate.is_document or candidate.is_triple
          mapping = candidate.mapping
          mapping.retract
          @binary_mappings.delete(object_type)
        end
      end

      def is_empty_inheritance mapping
        # Cannot be an empty inheritance unless it's an TypeInheritance absorption
        return false if !mapping.is_a?(MM::Absorption) || !mapping.parent_role.fact_type.is_a?(MM::TypeInheritance)

        # It's empty if it's a TypeInheritance which has no non-empty members
        !mapping.all_member.to_a.any? do |member|
          !is_empty_inheritance(member)
        end
      end

      def elide_empty_inheritance mapping
        mapping.all_member.to_a.each do |member|
          if member.is_a?(MM::Absorption) && member.parent_role.fact_type.is_a?(MM::TypeInheritance)
            elide_empty_inheritance(member)
            if member.all_member.size == 0
              trace :docgraph, "Retracting empty inheritance #{member.inspect}"
              member.retract
            end
          end
        end
      end

      # Absorb all items which aren't documents (and keys to those which are) recursively
      def absorb_all_properties
        trace :docgraph_properties!, "Computing contents of all documents and triples" do
          @document_composites.values.sort_by{|composite| composite.mapping.name}.each do |composite|
            trace :docgraph_properties, "Computing contents of #{composite.mapping.name}" do
              absorb_all(composite.mapping, composite.mapping)
            end
          end
        end
      end

      #
      # Rename parents functions defined because they are used in both Staging and Datavault subclasses
      #
      def apply_name pattern, name
        pattern.sub(/\+/, name)
      end

      def rename_parents
        @document_composites.each do |key, composite|
          composite.mapping.name = apply_name(@option_stg_name, composite.mapping.name)
        end
      end

      # This member is an Absorption. Process it recursively, either absorbing all its members if it is not a document,
      # deleting it if it is a semantic triple or just keeping the key if it is not a semantic triple
      def absorb_subdoc mapping, member, paths, stack
        trace :docgraph_properties, "Absorb subdoc of #{member.inspect} into #{mapping.name}" do
          # In the DocGraph composition, either absorb the contents or devolve a triple
          trace :docgraph_properties, "(parent #{member.parent_role.object_type.name}, child #{member.child_role.object_type.name})"
          child_object_type = member.child_role.object_type
          child_mapping = @binary_mappings[child_object_type]
          if @triple_composites[child_object_type]
            trace :docgraph_triple, "Eliminate #{child_object_type.name} subdoc"
            member.retract
            mapping.re_rank
            return
          end

          # Is our target object_type fully absorbed (and not through this absorption)?
          full_absorption = child_object_type.all_full_absorption[@composition]
          # We can't use member.full_absorption here, as it's not populated on forked copies
          # if full_absorption && full_absorption != member.full_absorption
          if full_absorption && full_absorption.absorption.parent_role.fact_type != member.parent_role.fact_type

            # REVISIT: This should be done by recursing to absorb_key, not using a loop
            absorption = member   # Retain this for the ForeignKey
            begin     # Follow transitive target absorption
              member = mirror(full_absorption.absorption, member)
              child_object_type = full_absorption.absorption.parent_role.object_type
            end while full_absorption = child_object_type.all_full_absorption[@composition]
            child_mapping = @binary_mappings[child_object_type]

            trace :docgraph_properties, "Absorbing all of #{member.child_role.name} in #{member.inspect_reading}"
            absorb_all(member, child_mapping, paths, stack)
            return
          end
          
          absorb_all(member, child_mapping, paths, stack)
        end
      end

      # Handle the reverse absorptions of the mapping
      def absorb_nested mapping, member, paths, stack
        trace :docgraph_properties, "Absorb nested of #{member.inspect} into #{mapping.name}" do
          # In the DocGraph composition, either absorb the contents or devolve a triple
          if @triple_composites[member.child_role.object_type]
            trace :docgraph_triple, "Handle #{member.inspect} as a semantic triple"
            member.retract
            mapping.re_rank
            return
          end

          # This is a nested structure, annotate as Nested, flip the member and absorb all
          x = @constellation.Nesting(:new, absorption: member, ordinal: 0, index_role: member.child_role)
          member.flip!
          child_object_type = member.child_role.object_type
          child_mapping = @binary_mappings[child_object_type]
          absorb_all(member, child_mapping, paths, stack)
        end
      end

      # May be overridden in subclasses
      def prefer_natural_key building_natural_key, source_composite, target_composite
        false
      end

      # Augment the mapping with copies of the children of the "from" mapping.
      # At the top level, no "from" is given and the children already exist
      def absorb_all mapping, from, paths = {}, stack = []
        trace :docgraph_properties, "Absorbing all from #{from.inspect} into #{mapping.name}" do
          top_level = mapping == from

          pcs = []
          newpaths = {}
          if mapping.composite || mapping.full_absorption
            pcs = find_uniqueness_constraints(mapping)

            # Don't build an index from the same PresenceConstraint twice on the same composite (e.g. for a subtype)
            existing_pcs = mapping.root.all_access_path.select{|ap| MM::Index === ap}.map(&:presence_constraint)
            newpaths = make_new_paths(mapping, paths.keys+existing_pcs, pcs)
          end

          from.re_rank
          substack = stack + [from.object_type]
          ordered = from.all_member.sort_by(&:ordinal)
          ordered.each do |member|
            trace :docgraph_properties, "... considering #{member.child_role.object_type.name}"
            
            # Only proceed if there is no absorption loop and we are not jumping to another document
            if !absorption_loop(member, substack) && !@document_composites[member.child_role.object_type]
              unless top_level    # Top-level members are already instantiated
                member = member.fork_to_new_parent(mapping)
              end
              rel = paths.merge(relevant_paths(newpaths, member))
              augment_paths(rel, member)

              if member.is_a?(MM::Absorption) && !member.forward_absorption && member.child_role.object_type.is_a?(MM::EntityType)
                # Only forward absorptions here please...
                absorb_subdoc(mapping, member, rel, substack)
              end
              if member.is_a?(MM::Absorption) && member.forward_absorption && top_level
                  # ! @document_composites[top(member.forward_absorption).object_type]
                absorb_nested(mapping, member, rel, substack)
              end
            end
          end

          # Clean up if mapping does not have any members
          if mapping.all_member.size == 0
            mapping_parent = mapping.parent
            mapping.retract
            mapping_parent.re_rank
          end

          newpaths.values.select{|ix| ix.all_index_field.size == 0}.each(&:retract)
        end
      end

      def absorption_loop(absorption, stack)
        trace :docgraph_properties, "Stack is #{stack.map{|ot| ot.name} * ', '}"
        result = stack.any? {|ot| ot == absorption.child_role.object_type}
        trace :docgraph_properties, "absorption child is #{absorption.child_role.object_type.name}, loop is #{result}"
        result
      end

      # Find all PresenceConstraints to index the object in this Mapping
      def find_uniqueness_constraints mapping
        return [] unless mapping.object_type.is_a?(MM::EntityType)

        start_roles =
            mapping.
            object_type.
            all_role_transitive.        # Includes objectification roles for objectified fact types
            select do |role|
              (role.is_unique ||                # Must be unique on near role
                role.fact_type.is_unary) &&     # Or be a unary role
              !(role.fact_type.is_a?(MM::TypeInheritance) && role == role.fact_type.supertype_role) # allow roles as subtype
            end.
            map(&:counterpart).         # (Same role if it's a unary)
            compact.                    # Ignore nil counterpart of a role in an n-ary
            map(&:base_role).           # In case it's a link fact type
            uniq

        pcs =
          start_roles.
          flat_map(&:all_role_ref).     # All role_refs
          map(&:role_sequence).         # The role_sequence
          uniq.
          flat_map(&:all_presence_constraint).
          uniq.
          reject do |pc|
            pc.max_frequency != 1 ||    # Must be unique
            pc.enforcement ||           # and alethic
            pc.role_sequence.all_role_ref.detect do |rr|
              !start_roles.include?(rr.role)    # and span only valid roles
            end ||                      # and not be the full absorption path
            (   # Reject a constraint that caused full absorption
              pc.role_sequence.all_role_ref.size == 1 and
              mapping.is_a?(MM::Absorption) and
              fa = mapping.full_absorption and
              pc.role_sequence.all_role_ref.single.role.base_role == fa.absorption.parent_role.base_role
            )
          end  # Alethic uniqueness constraint on far end

        non_absorption_pcs = pcs.reject do |pc|
          # An absorption PC is a PC that covers some role that is involved in a FullAbsorption
          full_absorptions =
            pc.
            role_sequence.
            all_role_ref.
            map(&:role).
            flat_map do |role|
              (role.all_absorption_as_parent_role.to_a + role.all_absorption_as_child_role.to_a).
                select do |abs|
                  abs.full_absorption && abs.full_absorption.composition == @composition
                end
            end
          full_absorptions.size > 0
        end
        pcs = non_absorption_pcs

        trace :docgraph_paths, "Uniqueness Constraints for #{mapping.object_type.name}" do
          pcs.each do |pc|
            trace :docgraph_paths, "#{pc.describe.inspect}#{pc.is_preferred_identifier ? ' (PI)' : ''}"
          end
        end

        pcs
      end

      def make_new_paths mapping, existing_pcs, pcs
        newpaths = {}
        new_pcs = pcs-existing_pcs
        trace :docgraph_paths, "Adding #{new_pcs.size} new indices for presence constraints on #{mapping.inspect}" do
          new_pcs.each do |pc|
            newpaths[pc] = index = @constellation.Index(:new, composite: mapping.root, is_unique: true, presence_constraint: pc)
            if mapping.object_type.preferred_identifier == pc and
                !@composition.all_full_absorption[mapping.object_type] and
                !mapping.root.natural_index
              mapping.root.natural_index = index
              mapping.root.primary_index ||= index    # Not if we have a surrogate already
            end
            trace :docgraph_paths, "Added new index #{index.inspect} for #{pc.describe} on #{pc.role_sequence.all_role_ref.map(&:role).map(&:fact_type).map(&:default_reading).inspect}"
          end
        end
        newpaths
      end

      def relevant_paths path_hash, component
        rel = {}  # REVISIT: return a hash subset of path_hash containing paths relevant to this component
        case component
        when MM::Absorption
          role = component.child_role.base_role
        when MM::Indicator
          role = component.role
        else
          return rel  # Can't participate in an AccessPath
        end

        path_hash.each do |pc, path|
          next unless pc.role_sequence.all_role_ref.detect{|rr| rr.role == role}
          rel[pc] = path
        end
        rel
      end

      def augment_paths paths, mapping
        return unless MM::Indicator === mapping || MM::ValueType === mapping.object_type

        if MM::ValueField === mapping && mapping.parent.composite   # ValueType that's a composite (table) by itself
          # This AccessPath has exactly one field and no presence constraint, so just make the index.
          composite = mapping.parent.composite
          paths[nil] =
            index = @constellation.Index(:new, composite: mapping.root, is_unique: true, presence_constraint: nil, composite_as_natural_index: composite)
          composite.primary_index ||= index
        end

        paths.each do |pc, path|
          trace :docgraph_paths, "Adding access path #{mapping.inspect} to #{path.inspect}" do
            case path
            when MM::Index
              @constellation.IndexField(access_path: path, ordinal: path.all_index_field.size, component: mapping)
            when MM::ForeignKey
              @constellation.ForeignKeyField(foreign_key: path, ordinal: path.all_foreign_key_field.size, component: mapping)
            end
          end
        end
      end

      # Make a new Absorption in the reverse direction from the one given
      def mirror absorption, parent
        @constellation.fork(
          absorption,
          guid: :new,
          object_type: absorption.parent_role.object_type,
          parent: parent,
          parent_role: absorption.child_role,
          child_role: absorption.parent_role,
          ordinal: 0,
          name: role_name(absorption.parent_role)
        )
      end

      # A candidate is a Mapping of an object type which may become a Composition (a table, in docgraph-speak)
      class Candidate
        attr_reader :mapping, :is_document, :is_triple, :is_tentative
        attr_accessor :full_absorption

        def initialize compositor, mapping
          @compositor = compositor
          @mapping = mapping
        end

        def object_type
          @mapping.object_type
        end

        # References from us are things we can own (non-Mappings) or have a unique forward absorption for
        def references_from
          @mapping.all_member.select{|m| !m.is_a?(MM::Absorption) or !m.forward_absorption && m.parent_role.is_unique }
        end
        alias_method :rf, :references_from

        # References to us are reverse absorptions where the forward absorption can absorb us
        def references_to
          @mapping.all_member.select{|m| m.is_a?(MM::Absorption) and f = m.forward_absorption and f.parent_role.is_unique}
        end
        alias_method :rt, :references_to

        def has_references
          @mapping.all_member.select{|m| m.is_a?(MM::Absorption) }
        end

        def definitely_not_document
          @is_tentative = @is_document = false
        end

        def definitely_document
          @is_tentative = false
          @is_document = true
          @is_triple = false
        end

        def definitely_not_triple
          @is_tentative = @is_triple = false
        end

        def definitely_triple
          @is_tentative = false
          @is_triple = true
          @is_document = false
        end

        def probably_not_document
          @is_tentative = true
          @is_document = false
        end

        def probably_document
          @is_tentative = @is_document = true
        end

        def assign_default composition
          o = object_type
          if o.is_separate
            trace :docgraph_defaults, "#{o.name} is a document because it's declared independent or separate"
            definitely_document
            return
          end
          
          if o.concept.all_concept_annotation.detect{|ca| ca.mapping_annotation =~ TRIPLE_ANNOTATION}
            trace :docgraph_defaults, "#{o.name} is a triple because it's declared triple"
            definitely_triple
            return
          end

          case o
          when MM::ValueType
            if o.is_auto_assigned
              trace :docgraph_defaults, "#{o.name} is not a document because it is auto assigned"
              definitely_not_document
            elsif references_from.size > 0
              trace :docgraph_defaults, "#{o.name} is a document because it has references to absorb"
              definitely_document
            else
              trace :docgraph_defaults, "#{o.name} is not a document because it will be absorbed wherever needed"
              definitely_not_document
            end

          when MM::EntityType
            if references_to.empty? and
                !references_from.detect do |absorption|   # detect whether anything can absorb this entity type
                  absorption.is_a?(MM::Mapping) && absorption.parent_role.is_unique # DG && absorption.child_role.is_unique
                end
              trace :docgraph_defaults, "#{o.name} is a document because it has nothing to absorb it"
              definitely_document
              return
            end
            
            # its a triple if this is an objectified fact type that has a uniqueness constraint of size = 2
            if o.fact_type
              # List the UCs on this fact type:
              all_uniqueness_constraints =
                o.fact_type.all_role.map do |fact_role|
                  fact_role.all_role_ref.map do |rr|
                    rr.role_sequence.all_presence_constraint.select { |pc| pc.max_frequency == 1 }
                  end
                end.flatten.uniq
            
              if all_uniqueness_constraints.detect do |uc|
                  (arr = uc.role_sequence.all_role_ref).size == 2 and arr[0].role.object_type.is_a?(MM::EntityType) and arr[1].role.object_type.is_a?(MM::EntityType)
                end
                trace :docgraph_defaults, "#{o.name} is a triple because is an objectified fact type with uniqueness contraint of 2"
                definitely_triple
                return
              end
            end
            
            if !o.supertypes.empty?
              # We know that this entity type is not a separate or partitioned subtype, so a supertype that can absorb us does
              identifying_fact_type = o.all_type_inheritance_as_subtype.detect{|ti| ti.provides_identification}
              if identifying_fact_type
                fact_type = identifying_fact_type
              else
                if o.all_type_inheritance_as_subtype.size > 1
                  trace :docgraph_defaults, "REVISIT: #{o.name} cannot be absorbed into a supertype that doesn't also absorb all our other supertypes (or is absorbed into one of its supertypes that does)"
                end
                fact_type = o.all_type_inheritance_as_subtype.to_a[0]
              end

              absorbing_ref = mapping.all_member.detect{|m| m.is_a?(MM::Absorption) && m.child_role.fact_type == fact_type}

              absorbing_ref = absorbing_ref.flip! if absorbing_ref.reverse_absorption   # We were forward, but the other end must be
              absorbing_ref = absorbing_ref.forward_absorption
              self.full_absorption =
                o.constellation.FullAbsorption(composition: composition, absorption: absorbing_ref, object_type: o)
              trace :docgraph_defaults, "Supertype #{fact_type.supertype_role.name} fully absorbs subtype #{o.name} via #{absorbing_ref.inspect}"
              definitely_not_document
              return
            end # subtype

            # If the preferred_identifier consists of a ValueType that's auto-assigned,
            # that can only happen in one document, which controls the sequence.
            auto_assigned_identifying_role_player = nil
            pi_role_refs = o.preferred_identifier.role_sequence.all_role_ref
            if pi_role_refs.size == 1 and
                rr = pi_role_refs.single and
                (v = rr.role.object_type).is_a?(MM::ValueType) and
                v.is_auto_assigned == 'commit'
              auto_assigned_identifying_role_player = v
            end
            if (@compositor.options['single_sequence'] || references_to.size > 1) and auto_assigned_identifying_role_player   # Can be absorbed in more than one place
              trace :docgraph_defaults, "#{o.name} must be a document to support its auto-assigned identifier #{auto_assigned_identifying_role_player.name}"
              definitely_document
              return
            end

            trace :docgraph_defaults, "#{o.name} is initially presumed to be a document"
            probably_document

          end   # case
        end

      end

    end

    publish_compositor(DocGraph)
  end
end
