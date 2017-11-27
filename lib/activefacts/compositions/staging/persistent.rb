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
# Where it differs is that all unique constraints are disabled, and
# replaced by a primary key that is the source schema's PK appended
# with the LoadBatchID. Each record also has a ValidUntil timestamp,
# which is NULL for the most recent record. This allows a load batch
# to load a new version of any record, and the key value will be
# adjacent to the previous versions of that record.
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

        def needs_surrogate(composite)
          composite.mapping.object_type != @loadbatch_entity_type
        end

        def complete_foreign_keys
          super

          remake_primary_keys
        end

        def remake_primary_keys
          trace :relational_paths, "Remaking primary keys" do
            @composition.all_composite.each do |composite|
              next if composite.mapping.object_type == @loadbatch_entity_type
              composite.all_access_path.each do |path|
                # Ignore foreign keys:
                next unless MM::Index === path

                # If we found the natural key, clone it as a modified primary key:
                if composite.natural_index == path
                  primary_key = @composition.constellation.fork(path, guid: :new)
                  composite.primary_index = primary_key
                  path.all_index_field.each do |ixf|
                    @composition.constellation.fork(ixf, access_path: primary_key)
                  end

                  # Add LoadBatchID to the new primary index:
                  trace :index, "Appending LoadBatch to primary key #{primary_key.inspect}" do
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
                    absorption = absorptions[0]
                    absorption.all_leaf.each do |leaf|
                      @constellation.IndexField(access_path: primary_key, ordinal: primary_key.all_index_field.size, component: leaf)
                    end
                  end
                  composite.natural_index.is_unique = false
                elsif path.is_unique
                  # Don't retract the surrogate
                  next if path.all_index_field.size == 1 && MM::SurrogateKey === path.all_index_field.single.component

                  # Make other unique keys non-unique:
                  trace :index, "Make secondary #{path.inspect} non-unique" do
                    path.is_unique = false
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
