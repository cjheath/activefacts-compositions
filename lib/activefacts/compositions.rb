require "activefacts/metamodel"
require "activefacts/compositions/version"
require "activefacts/compositions/compositor"

module ActiveFacts
  module Compositions
    def self.compositors
      @@compositors ||= {}
    end

    def self.publish_compositor klass, helptext = ''
      compositors[klass.name.sub(/^ActiveFacts::Compositions::/,'').gsub(/::/, '/').downcase] = [klass, helptext]
    end
  end
end
