require 'activefacts/compositions'
require 'active_support'
require 'digest/sha1'

module ActiveFacts
  module Metamodel
    class Component
      def rails
        @rails_facet ||= ACTR::Component.new(self)
      end
    end

    class Index
      def rails
        @rails_facet ||= ACTR::Index.new(self)
      end
    end

    class ForeignKey
      def rails
        @rails_facet ||= ACTR::ForeignKey.new(self)
      end
    end

    class Composite
      def rails
        @rails_facet ||= ACTR::Composite.new(self)
      end
    end
  end

  module Composition
    module Traits
      module Rails
        def self.name_trunc name
          if name.length > 63
            hash = Digest::SHA1.hexdigest name
            name = name[0, 53] + '__' + hash[0, 8]
          end
          name
        end

        def self.plural_name name
          # Crunch spaces and pluralise the first part, all in snake_case
          name.pop if name.is_a?(Array) and name.last == []
          name = name[0]*'_' if name.is_a?(Array) and name.size == 1
          if name.is_a?(Array)
            name = ActiveSupport::Inflector.tableize((name[0]*'_').gsub(/\s+/, '_')) +
              '_' +
              ActiveSupport::Inflector.underscore((name[1..-1].flatten*'_').gsub(/\s+/, '_'))
          else
            ActiveSupport::Inflector.tableize(name.gsub(/\s+/, '_'))
          end
        end

        def self.singular_name name
          # Crunch spaces and convert to snake_case
          name = name.flatten*'_' if name.is_a?(Array)
          ActiveSupport::Inflector.underscore(name.gsub(/\s+/, '_'))
        end

        class Facet
          def initialize base
            @base = base
          end

          def method_missing m, *a, &b
            @base.send(m, *a, &b)
          end
        end

        class Component < Facet
          def name
            ACTR::singular_name(@base.name)
          end
          
          def plural_name
            ACTR::plural_name(@base.name)
          end

          def type
            type_name, params, constraints = *explode.type()
            rails_type = case type_name
              when /^Auto ?Counter$/i
                'serial'        # REVISIT: Need to detect surrogate ID fields and handle them correctly

              when /^[Ug]uid$/i
                'uuid'

              when /^Unsigned ?Integer$/i,
                /^Integer$/i,
                /^Signed ?Integer$/i,
                /^Unsigned ?Small ?Integer$/i,
                /^Signed ?Small ?Integer$/i,
                /^Unsigned ?Tiny ?Integer$/i
                length = nil
                'integer'

              when /^Decimal$/i
                'decimal'

              when /^Float$/i, /^Double$/i, /^Real$/i
                'float'

              when /^Fixed ?Length ?Text$/i, /^Char$/i
                'string'
              when /^Variable ?Length ?Text$/i, /^String$/i
                'string'
              when /^Large ?Length ?Text$/i, /^Text$/i
                'text'

              when /^Date ?And ?Time$/i, /^Date ?Time$/i
                'datetime'
              when /^Date$/i
                'date'
              when /^Time$/i
                'time'
              when /^Auto ?Time ?Stamp$/i
                'timestamp'

              when /^Money$/i
                'decimal'
              when /^Picture ?Raw ?Data$/i, /^Image$/i, /^Variable ?Length ?Raw ?Data$/i, /^Blob$/i
                'binary'
              when /^BIT$/i, /^Boolean$/i
                'boolean'
              else
                type_name # raise "ActiveRecord type unknown for standard type #{type}"
              end
            [rails_type, params[:length]]
          end
        end

        class Index < Facet
          def name
            column_names = columns.map{|c| c.rails.name }
            index_name = "index_#{on.rails.name+'_on_'+column_names*'_'}"
            ACTR.name_trunc index_name
          end
        end

        class ForeignKey < Facet
          # A foreign key is between two Composites, but involves some Absorption that traverses
          # between two object types, either or both of which may be fully absorbed into the
          # respective Composites. The name of a foreign key takes this into account.

          def from_association_name
            absorption.column_name.snakecase
          end

          def to_association
            if absorption && absorption.child_role.is_unique
              [ "has_one", source_composite.rails.singular_name]
            else
              [ "has_many", source_composite.rails.plural_name]
            end
          end
        end

        class Composite < Facet
          def plural_name
            ACTR::plural_name(@base.mapping.name)
          end

          def singular_name
            ACTR::singular_name(@base.mapping.name)
          end

          def class_name
            ActiveSupport::Inflector.camelize(@base.mapping.name.gsub(/\s+/, '_'))
          end
        end

      end
    end
  end

  private
    ACTR = Composition::Traits::Rails
end
