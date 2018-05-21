#
#       ActiveFacts Rails Models Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/compositions'
require 'activefacts/generator'
require 'activefacts/compositions/traits/rails'

module ActiveFacts
  module Generators
    module Rails
      class Models
        HEADER = "# Auto-generated from CQL, edits will be lost"
        def self.options
          ({
            keep:       ['Boolean', "Keep stale model files"],
            output:     [String,    "Overwrite model files into this output directory"],
            concern:    [String,    "Namespace for the concerns"],
            validation: ['Boolean', "Disable generation of validations"],
          })
        end

        def self.compatibility
          # REVISIT: We depend on the surrogate option being enabled if any PK is not Rails-friendly
          [1, %i{relational}]   # one relational composition
        end

        def initialize composition, options = {}
          @composition = composition
          @options = options
          @option_keep = options.delete("keep")
          @option_output = options.delete("output")
          @option_concern = options.delete("concern")
          @option_validations = options.include?('validations') ? options.delete("validations") : true
        end

        def warn *a
          $stderr.puts *a
        end

        def generate
          list_extant_files if @option_output && !@option_keep

          @ok = true
          models =
            @composition.
            all_composite.
            sort_by{|composite| composite.mapping.name}.
            map{|composite| generate_composite composite}.
            compact*"\n"

          warn "\# #{@composition.name} generated with errors" unless @ok
          delete_old_generated_files if @option_output && !@option_keep

          models
        end

        def list_extant_files
          @preexisting_files = Dir[@option_output+'/*.rb']
        end

        def delete_old_generated_files
          remaining = []
          cleaned = 0
          @preexisting_files.each do |pathname|
            if generated_file_exists(pathname) == true
              File.unlink(pathname) 
              cleaned += 1
            else
              remaining << pathname
            end
          end
          $stderr.puts "Cleaned up #{cleaned} old generated files" if @preexisting_files.size > 0
          $stderr.puts "Remaining non-generated files:\n\t#{remaining*"\n\t"}" if remaining.size > 0
        end

        def generated_file_exists pathname
          File.open(pathname, 'r') do |existing|
            first_lines = existing.read(1024)     # Make it possible to pass over a magic charset comment
            if first_lines.length == 0 or first_lines =~ %r{^#{HEADER}}
              return true
            end
          end
          return false    # File exists, but is not generated
        rescue Errno::ENOENT
          return nil      # File does not exist
        end

        def create_if_ok filename
          # Create a file in the output directory, being careful not to overwrite carelessly
          out = $stdout
          if @option_output
            pathname = (@option_output+'/'+filename).gsub(%r{//+}, '/')
            @preexisting_files.reject!{|f| f == pathname }    # Don't clean up this file
            if generated_file_exists(pathname) == false
              warn "not overwriting non-generated file #{pathname}"
              @ok = false
              return nil
            end
            out = File.open(pathname, 'w')
          end
          out
        end

        def generate_composite composite
          model =
            (@option_concern ? "module #{@option_concern}\n" : '') +
            model_body(composite).gsub(/^./, @option_concern ? '  \0' : '\0') +
            (@option_concern ? "end\n" : '')

          return model unless @option_output

          filename = composite.rails.singular_name+'.rb'
          out = create_if_ok(filename)
          return nil unless out
          out.puts "#{HEADER}\n\n"+model
        ensure
          out.close if out
          nil
        end

        def model_header composite
          [
          "module #{composite.rails.class_name}",
          "  extend ActiveSupport::Concern",
          "  included do"
          ]
        end

        def model_key composite
          identifier_columns = composite.primary_index.all_index_field
          if identifier_columns.size == 1
            [
            "    self.primary_key = '#{identifier_columns.single.component.column_name.snakecase}'",
            ''    # Leave a blank line
            ]
          else
            []
          end
        end

        def model_body composite
          (
            model_header(composite) +
            model_key(composite) +
            to_associations(composite) +
            from_associations(composite) +
            column_constraints(composite) +
            [
            "  end",
            "end"
            ]
          ).
          compact.
          map{|l| l+"\n"}.
          join('').
          gsub(/\n\n\n+/,"\n\n")  # At most double-spaced
        end

        def to_associations composite
          # Each outbound foreign key generates a belongs_to association:
          composite.all_foreign_key_as_source_composite.
          sort_by{ |fk| fk.all_foreign_key_field.map(&:component).flat_map(&:path).map(&:rank_key) }.
          flat_map do |fk|
            next nil if fk.all_foreign_key_field.size > 1
            association_name = fk.rails.from_association_name

            if association_name != fk.composite.rails.singular_name
              # A different class_name is implied, emit an explicit one:
              class_name = ", :class_name => '#{fk.composite.rails.class_name}'"
            end

            foreign_key = ", :foreign_key => :#{fk.all_foreign_key_field.single.component.column_name.snakecase}"
            if foreign_key == fk.composite.rails.singular_name+'_id'
              # See lib/active_record/reflection.rb, method #derive_foreign_key
              foreign_key = ''
            end

            single_fk_field = fk.all_foreign_key_field.single.component
            if !single_fk_field.path_mandatory
              optional = ", :optional => true"
            end

            [
            fk.mapping ? "    \# #{fk.mapping.comment}" : nil,
            "    belongs_to :#{association_name}#{class_name}#{foreign_key}#{optional}",
            fk.mapping ? '' : nil,
            ]
          end.compact
        end

        def from_associations composite
          # has_one/has_many Associations
          composite.all_foreign_key_as_target_composite.
          sort_by{ |fk| fk.all_foreign_key_field.map(&:component).flat_map(&:path).map(&:rank_key) }.
          flat_map do |fk|
            next nil if fk.all_foreign_key_field.size > 1

            if fk.all_foreign_key_field.size > 1
              raise "Can't emit Rails associations for multi-part foreign key with #{fk.all_foreign_key_field.inspect}. Did you mean to use --surrogate?"
            end

            association_type, association_name = *fk.rails.to_association

            [
              # REVISIT: We want the reverse-order comment here really
              fk.mapping ? "    \# #{fk.mapping.comment}" : nil,
              %Q{    #{association_type} :#{association_name}} +
              %Q{, :class_name => '#{fk.source_composite.rails.class_name}'} +
              %Q{, :foreign_key => :#{fk.all_foreign_key_field.single.component.column_name.snakecase}} +
              %Q{, :dependent => :destroy}
            ] +
            # If fk.mapping.source_composite is a join table, we can emit a has_many :through for each other key
            # REVISIT: We could alternately do this for all belongs_to's in the source composite
            if fk.source_composite.primary_index.all_index_field.size > 1
              fk.source_composite.primary_index.all_index_field.map(&:component).flat_map do |ic|
                next nil if ic.is_a?(MM::Indicator)      # or use rails.plural_name(ic.references[0].to_names) ?
                onward_fks = ic.all_foreign_key_field.map(&:foreign_key)
                next nil if onward_fks.size == 0 or onward_fks.detect{|ofk| ofk.composite == composite} # Skip the back-reference
                # This far association name needs to be augmented for its role name
                # so the reverse associations still work for customised association names
                source =
                  if composite.rails.singular_name != fk.rails.from_association_name
                    ", :source => :#{fk.rails.from_association_name}"
                  else
                    ''
                  end
                "    has_many :#{onward_fks[0].composite.rails.plural_name}, :through => :#{association_name}#{source}"
              end.compact
            else
              []
            end +
            [fk.mapping ? '' : nil]
          end.compact
        end

        def column_constraints composite
          return [] unless @option_validations
          ccs =
            composite.mapping.all_leaf.flat_map do |component|
              next unless component.path_mandatory && !component.is_a?(Metamodel::Indicator)
              next if composite.primary_index != composite.natural_index && composite.primary_index.all_index_field.detect{|ixf| ixf.component == component}
              next if component.is_a?(Metamodel::Mapping) && component.object_type.is_a?(Metamodel::ValueType) && component.is_auto_assigned
              if component.all_foreign_key_field.size == 0
                [ "    validates :#{component.column_name.snakecase}, :presence => true" ]
              end
            end.compact
          ccs.unshift("") unless ccs.empty?
          ccs
        end

        MM = ActiveFacts::Metamodel unless const_defined?(:MM)
      end
    end
    publish_generator Rails::Models, "Generate models in Ruby for use with ActiveRecord and Rails. Use a relational compositor"
  end
end
