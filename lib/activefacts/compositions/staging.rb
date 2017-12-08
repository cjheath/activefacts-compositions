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
        merge(Relational.options)
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        datavault_initialize options
        @option_stg_name = options.delete('stgname') || 'STG'
        @option_stg_name.sub!(/^/,'+ ') unless @option_stg_name =~ /\+/
        @fk_natural = true

        super constellation, name, options, 'Staging'
      end

      def needs_surrogate(composite)
        @option_surrogates && composite.mapping.object_type != @loadbatch_entity_type
      end

      def generate
        create_loadbatch if @option_audit == 'batch'
        super
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
      end

    end

    publish_compositor(Staging)
  end
end
