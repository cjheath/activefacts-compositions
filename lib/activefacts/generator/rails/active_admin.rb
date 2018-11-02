#
#       ActiveFacts Rails Models Generator
#
# Copyright (c) 2018 Daniel Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/compositions/traits/rails'
require 'activefacts/generator/rails/ruby_folder_generator'

module ActiveFacts
  module Generators
    module Rails
      class ActiveAdmin
        include RubyFolderGenerator
        def self.options
          ({
            keep:          ['Boolean', "Keep stale files"],
            output:        [String,    "Write admin config files into this output directory"],
          })
        end

        def self.compatibility
          # REVISIT: We depend on the surrogate option being enabled if any PK is not Rails-friendly
          [1, %i{relational}]   # one relational composition
        end

        def initialize constellation, composition, options = {}
          @constellation = constellation
          @composition = composition
          @options = options
          @option_keep = options.delete("keep")
          @option_output = options.delete("output")
          @option_output ||= 'app/admin'
          @option_output = nil if @option_output == "-"
        end

        def generate_files
          admins =
            @composition.
            all_composite.
            sort_by{|composite| composite.mapping.name}.
            map{|composite| generate_admin composite}.
            compact*"\n"
        end

        def extant_files
          Dir[@option_output+'/*.rb']
        end

        def generate_admin composite
          columns = composite.mapping.all_leaf.flat_map do |component|
            # Absorbed empty subtypes appear as leaves
            next [] if component.is_a?(MM::Absorption) && component.parent_role.fact_type.is_a?(MM::TypeInheritance)
            ':' + component.column_name.snakecase
          end

          model = "ActiveAdmin.register #{composite.rails.class_name} do\n  permit_params #{columns.join(', ')}\nend\n"

          return model unless @option_output

          filename = composite.rails.singular_name+'_admin.rb'
          out = create_if_ok(@option_output, filename)
          return nil unless out
          out.puts "#{HEADER}\n" +
            "\# #{([File.basename($0)]+ARGV)*' '}\n\n" +
            model
        ensure
          out.close if out
          nil
        end

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
      end
    end
    publish_generator Rails::ActiveAdmin, "Generate models in Ruby for use with ActiveAdmin and Rails. Use a relational compositor"
  end
end
