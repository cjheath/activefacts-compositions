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
        }).
        merge(Relational.options).
        reject{|k,v| [:surrogates].include?(k) }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        datavault_initialize options
        @option_stg_name = options.delete('stgname') || 'STG'
        @option_stg_name.sub!(/^/,'+ ') unless @option_stg_name =~ /\+/

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

    end

    publish_compositor(Staging)
  end
end
