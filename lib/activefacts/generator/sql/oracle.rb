#
#       ActiveFacts Oracle SQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/sql'
require 'activefacts/generator/traits/sql/oracle'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * underscore 
    class SQL
      class Oracle < SQL
        prepend Traits::SQL::Oracle
        extend Traits::SQL::Oracle   # Needed for class methods, like options
      end

    end
    publish_generator SQL::Oracle
  end
end
