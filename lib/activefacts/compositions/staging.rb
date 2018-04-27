#
# ActiveFacts Compositions, Staging Compositor.
#
#       Computes a Staging schema for Data Vault.
#
# Copyright (c) 2016 Graeme Port. Read the LICENSE file.
#
require "activefacts/compositions/relational"
require "activefacts/compositions/traits/datavault"

module ActiveFacts
  module Compositions
    class Staging < Relational
      extend Traits::DataVault
      include Traits::DataVault
    public
      def self.options
        datavault_options.
        merge({
          cdc: [%w{record satellite all}, "Add computed hash fields for change detection"],
          persistent: ['Boolean', "Allow multiple batches to be loaded into the same tables"],
          stgname: ['String', "Suffix or pattern for naming staging tables. Include a + to insert the name. Default 'STG'"],
        }).
        merge(Relational.options)
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        @option_cdc = options.delete('cdc')

        @option_persistent = options.delete('persistent')
        options = {'surrogates'=>'Record GUID'}.    # You must have surrogates, but can call them what you wish
          merge(options).merge({'fk'=>'natural', 'audit'=>'batch'}) if @option_persistent          # Must be batch auditing

        @option_stg_name = options.delete('stgname') || 'STG'
        @option_stg_name.sub!(/^/,'+ ') unless @option_stg_name =~ /\+/

        datavault_initialize options

        @option_fk = :natural      # Default value
        super constellation, name, options, 'Staging'
      end

      def complete_foreign_keys
        super

        augment_keys if @option_persistent
      end

      def needs_surrogate(composite)
        @option_surrogates && composite.mapping.object_type != @loadbatch_entity_type
      end

      def inject_surrogates
        assign_groups
        super
      end

      def assign_groups
        @composites.values.each{|composite| composite.composite_group = 'base' }
        loadbatch_composite.composite_group = 'batch' if @option_audit == 'batch'
      end

      def generate
        create_loadbatch if @option_audit == 'batch'
        super
      end

      # Find the leaf absorption of the LoadBatchID in composite
      def load_batch_field composite
        load_batch_role =
          composite.mapping.object_type.all_role.detect do |role|
            c = role.counterpart and c.object_type == @loadbatch_entity_type
          end
        trace :index, "Found LoadBatch role in #{load_batch_role.fact_type.default_reading}" if load_batch_role
        # There can only be one absorption of LoadBatch, because we added it,
        # but if you have separate subtypes, we need to select the one for the right composite:
        absorptions = load_batch_role.
          counterpart.
          all_absorption_as_child_role.
          select{|a| a.root == composite}
        # There should now always be exactly one.
        raise "Missing or ambiguous FK to LoadBatch from #{composite.inspect}" if absorptions.size != 1
        absorptions[0].all_leaf[0]
        # This is the absorption of LoadBatchID
      end

      def inject_all_audit_fields
        inject_loadbatch_relationships if @option_audit == 'batch'
      end

      def apply_all_audit_transformations
        composites = @composition.all_composite.to_a
        return if composites.empty?

        trace :staging, "Injecting load datetime and record source" do
          @composition.all_composite.each do |composite|
            is_loadbatch_composite = composite.mapping.object_type == @loadbatch_entity_type
            composite.mapping.injection_annotation = 'loadbatch' if is_loadbatch_composite
            if @option_audit == 'record' || is_loadbatch_composite
              inject_audit_fields composite
              composite.mapping.re_rank
            end
          end
        end
      end

      def apply_schema_transformations
        # Rename composites with STG prefix
        apply_composite_name_pattern

        apply_all_audit_transformations

        super
      end

      def augment_keys
        trace :index, "Augmenting keys" do
          @composition.all_composite.each do |composite|
            next if composite.mapping.object_type == @loadbatch_entity_type
            target_batch_id = load_batch_field(composite)
            composite.all_access_path.each do |path|
              # Ignore foreign keys and non-unique indices:
              next unless MM::Index === path and path.is_unique

              # Don't meddle with the surrogate
              next if path.all_index_field.size == 1 && MM::SurrogateKey === path.all_index_field.single.component

              trace :index, "Add LoadBatchID to #{path.inspect}" do
                @constellation.IndexField(access_path: path, ordinal: path.all_index_field.size, component: target_batch_id)
              end

              # Note that the RecordGUID will have become the primary key.
              # Foreign keys would be enforced onto the natural key, but we
              # want the natural key to be clustering, so we switch them around
              if composite.natural_index == path
                pk = composite.primary_index
                composite.primary_index = composite.natural_index
                composite.natural_index = pk

                # Fix the foreign keys that use this changed natural key:
                trace :index, "Appending LoadBatch to foreign keys to #{composite.mapping.name}" do
                  composite.
                  all_foreign_key_as_target_composite.
                  each do |fk|
                    trace :index, "Appending LoadBatch to #{fk.inspect}" do
                      source_batch_id = load_batch_field(fk.source_composite)
                      trace :index, "ForeignKeyField is #{source_batch_id.root.mapping.name}.#{source_batch_id.inspect}"
                      trace :index, "IndexField is #{target_batch_id.root.mapping.name}.#{target_batch_id.inspect}"
                      @constellation.ForeignKeyField(foreign_key: fk, ordinal: fk.all_foreign_key_field.size, component: source_batch_id)
                      @constellation.IndexField(access_path: fk, ordinal: fk.all_index_field.size, component: target_batch_id)
                    end
                  end
                end
              end

            end
          end
        end
      end

    end

    publish_compositor Staging, "A relational composition augmented with audit attributes for staging data transformations"
  end
end
