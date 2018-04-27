require "activefacts/metamodel"
require "activefacts/compositions/version"

module ActiveFacts
  module Generators
    def self.generators
      @@generators ||= {}
    end

    def self.publish_generator klass, helptext = ''
      generators[klass.name.sub(/^ActiveFacts::Generators::/,'').gsub(/::/, '/').downcase] = [klass, helptext]
    end
  end
end
