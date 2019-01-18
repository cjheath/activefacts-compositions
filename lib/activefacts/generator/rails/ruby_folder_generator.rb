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
require 'fileutils'

module ActiveFacts
  module Generators
    module Rails
      module RubyFolderGenerator
        HEADER = "# Auto-generated (edits will be lost) using:"

        def warn *a
          $stderr.puts *a
        end

        def generate
          record_extant_files_to_remove

          @ok = true
          result = generate_files

          warn "\# #{@composition.name} generated with errors" unless @ok
          delete_old_generated_files if @option_output && !@option_keep

          result
        end

        def record_extant_files_to_remove
          @preexisting_files = []
          return if @option_keep
          @preexisting_files = extant_files || []
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
            if first_lines.length == 0 or first_lines =~ %r{^#{Regexp.quote HEADER}}
              return true
            end
          end
          return false    # File exists, but is not generated
        rescue Errno::ENOENT
          return nil      # File does not exist
        end

        def create_if_ok dir, filename
          # Create a file in the output directory, being careful not to overwrite carelessly
          out = $stdout
          if dir
            FileUtils.mkdir_p(dir)
            pathname = (dir+'/'+filename).gsub(%r{//+}, '/')
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
      end
    end
  end
end
