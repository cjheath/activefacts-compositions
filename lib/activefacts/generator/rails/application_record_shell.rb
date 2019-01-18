#
#       ActiveFacts Rails Models Generator
#
# Copyright (c) 2009-2016 Daniel Heath. Read the LICENSE file.
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
      class ApplicationRecordShell
        include RubyFolderGenerator
        def self.options
          ({
            keep:          ['Boolean', "Keep stale model files"],
            validation:    ['Boolean', "Disable generation of validations"],
            concern:       [String,    "Namespace for the concerns"],
            output:        [String,    "Generate models in given directory (as well as concerns)"],
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
          @option_concern = options.delete("concern")

          @option_output = options.delete("output")
          if !@option_output
            @option_output = "app/models"
          end
          @option_output = nil if @option_output == "-" # dash for stdout
        end

        def generate_files
          @composition.
          all_composite.
          sort_by{|composite| composite.mapping.name}.
          map{|composite| generate_model composite}.
          compact*"\n"
        end

        def extant_files
          Dir[@option_output+'/*.rb'] if @option_output
        end

        def generate_model composite
          concern_module = @option_concern ? "#{@option_concern}::" : ""
          model = "class #{composite.rails.class_name} < ApplicationRecord\n  include #{concern_module}#{composite.rails.class_name}\nend\n"

          return model unless @option_output

          filename = composite.rails.singular_name+'.rb'
          out = create_if_ok(@option_output, filename)
          return nil unless out
          out.puts "#{HEADER}\n" +
            "\# #{([File.basename($0)]+ARGV)*' '}\n\n" +
            model
        ensure
          out.close if out
          nil
        end
      end
    end
    publish_generator Rails::ApplicationRecordShell, "Generate ApplicationRecord shell in Ruby for use with ActiveRecord and Rails. Use a relational compositor"
  end
end
