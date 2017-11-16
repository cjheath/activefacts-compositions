#
#       ActiveFacts PostgreSQL Schema Generator
#
# Copyright (c) 2017 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/sql'
require 'activefacts/generator/traits/sql/postgres'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * underscore 
    class SQL
      class Postgres < SQL
        include Traits::SQL::Postgres
        extend Traits::SQL::Postgres   # Needed for class methods, like options
      end

    end
    publish_generator SQL::Postgres
  end
end
