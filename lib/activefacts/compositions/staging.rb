#
# ActiveFacts Compositions, Staging Compositor.
#
#       Computes a Staging schema for Data Vault.
#
# Copyright (c) 2016 Graeme Port. Read the LICENSE file.
#
require "activefacts/compositions/relational"

module ActiveFacts
  module Compositions
    class Staging < Relational
    public
      def self.options
        {
          stgname: ['String', "Suffix or pattern for naming staging tables. Include a + to insert the name. Default 'STG'"],
        }
      end

      def initialize constellation, name, options = {}
        # Extract recognised options:
        @option_stg_name = options.delete('stgname') || 'STG'
        @option_stg_name.sub!(/^/,'+ ') unless @option_stg_name =~ /\+/

        super constellation, name, options

      end

      def inject_all_datetime_recordsource
        composites = @composition.all_composite.to_a
        return if composites.empty?

        trace :staging, "Injecting load datetime and record source" do
          @composition.all_composite.each do |composite|
            inject_datetime_recordsource composite.mapping
            composite.mapping.re_rank
          end
        end
      end

      def devolve_all
        # Rename composites with STG prefix
        rename_parents
      end
    end

    publish_compositor(Staging)
  end
end
