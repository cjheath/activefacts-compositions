#
# ActiveFacts Compositions, Staging Compositor.
#
#       Computes a Persistent Staging schema for Data Vault.
#
# Copyright (c) 2017 Clifford Heath. Read the LICENSE file.
#
# This style of staging area contains a table for every source table,
# with injected foreign keys to a LoadBatch table, as for transient
# staging.
#
# Where it differs is that all unique constraints are appended with
# the LoadBatchID. This allows multiple complete copies of the source
# data to be loaded.
#
# Each record also has a ValidUntil timestamp, which is NULL for the
# most recent record. This allows a load batch to load a new version
# of any record, and the key value will be adjacent to the previous
# versions of that record.
#
# After a batch is complete, any updated record keys will address
# more than one record with a NULL ValidUntil timestamp, and this
# allows delta detection. As a delta is processed, the older record
# can be marked as valid only until the current LoadBatch time, or
# it can be deleted. If retained, a purge process can remove records
# that have exceeded their useful lifetime.
#
# Note that this approach doesn't directly detect deleted records.
# If the source system uses soft deletion, this generator can be
# configured with the name and value of the deleted flag field(s).
# This approach also works to manage CDC systems, which provide a
# record-deleted flag.
#

require "activefacts/compositions/staging"

module ActiveFacts
  module Compositions
    class Staging
      class Persistent < Staging
      public
        def self.options
          super.
          merge({
            # Add Persistent options here
          }).
          reject{|k,v| [:loadbatch].include?(k) }
        end

        def initialize constellation, name, options = {}
          # Extract recognised options:
          super(constellation, name, {'surrogates'=>'Record GUID', 'fk'=>'natural', "loadbatch"=>true}.merge(options))

          raise "--staging/persistent requires the loadbatch option (you can't disable it)" unless @option_loadbatch
        end

        def complete_foreign_keys
          super

          augment_keys
        end

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
      end # Persistent
    end   # Staging
    publish_compositor(Staging::Persistent)
  end
end
