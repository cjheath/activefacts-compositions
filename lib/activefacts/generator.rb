require "activefacts/metamodel"
require "activefacts/compositions/version"

module ActiveFacts
  module Generators
    private
      MM = ActiveFacts::Metamodel
      
    def self.generators
      @@generators ||= {}
    end

    def self.publish_generator klass
      generators[klass.name.sub(/^ActiveFacts::Generators::/,'').gsub(/::/, '/').downcase] = klass
    end
  end
end
