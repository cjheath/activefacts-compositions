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
          stgname: ['String', "Suffix or pattern for naming staging tables. Include a + to insert the name. Default 'STG'"],
          fk: ['Boolean', "Retain foreign keys in the output (by default they are deleted)"]
        }).
        merge(Relational.options).
        reject{|k,v| [:surrogates].include?(k) }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        datavault_initialize options
        @option_stg_name = options.delete('stgname') || 'STG'
        @option_stg_name.sub!(/^/,'+ ') unless @option_stg_name =~ /\+/

        @option_keep_fks = options.delete('fk') || false
        @option_keep_fks = ['', true, 'true', 'yes'].include?(@option_keep_fks)

        super constellation, name, options, 'Staging'
      end

      def generate
        create_loadbatch if @option_loadbatch
        super
      end

      def inject_value_fields
        super
        inject_loadbatch_relationships if @option_loadbatch
      end

      def inject_all_datetime_recordsource
        composites = @composition.all_composite.to_a
        return if composites.empty?

        trace :staging, "Injecting load datetime and record source" do
          @composition.all_composite.each do |composite|
            next if composite.mapping.object_type.name == @option_loadbatch
            inject_datetime_recordsource composite.mapping
            composite.mapping.re_rank
          end
        end
      end

      def apply_schema_transformations
        # Rename composites with STG prefix
        apply_composite_name_pattern

        inject_all_datetime_recordsource
      end

      def complete_foreign_keys
        if @option_keep_fks
          super
        else
          retract_foreign_keys
        end
      end

      def retract_foreign_keys
        trace :relational_paths, "Retracting foreign keys" do
          @composition.all_composite.each do |composite|
            composite.all_access_path.each do |path|
              next if MM::Index === path
              trace :relational_paths, "Retracting #{path.inspect}" do
                path.retract
              end
            end
          end
        end
      end

    end

    publish_compositor(Staging)
  end
end
