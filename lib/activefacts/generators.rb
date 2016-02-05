require "activefacts/metamodel"
require "activefacts/compositions/version"

module ActiveFacts
  module Generators
    def self.generators
      @@generators ||= {}
    end

    def self.publish_generator klass
      generators[klass.basename.downcase] = klass
    end
  end
end
