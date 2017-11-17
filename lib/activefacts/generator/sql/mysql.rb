#
#       ActiveFacts MySQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator/sql'
require 'activefacts/generator/traits/sql/mysql'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * underscore 
    class SQL
      class MySQL < SQL
        include Traits::SQL::MySQL
        extend Traits::SQL::MySQL   # Needed for class methods, like options
      end

    end
    publish_generator SQL::MySQL
  end
end
