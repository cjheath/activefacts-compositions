#
# Test the relational composition from CQL files by comparing generated Datavault summary output
#

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

# require 'spec_helper'
require 'activefacts/compositions/docgraph'
# require 'activefacts/compositions/names'
require 'activefacts/generator/summary'
# require 'activefacts/generator/sql'
require 'activefacts/input/cql'

DG_CQL_DIR = Pathname.new(__FILE__+'/../cql').relative_path_from(Pathname(Dir.pwd)).to_s
DG_TEST_DIR = Pathname.new(__FILE__+'/..').relative_path_from(Pathname(Dir.pwd)).to_s

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual == expected
  end

  failure_message do
    'Output doesn\'t match expected, see diff'
  end

  diffable
end

describe "DocGraph schema from CQL" do
  dir = ENV['CQL_DIR'] || DG_CQL_DIR
  actual_dir = (ENV['CQL_DIR'] ? '' : DG_TEST_DIR+'/') + 'actual'
  expected_dir = (ENV['CQL_DIR'] ? '' : DG_TEST_DIR+'/') + 'expected'
  Dir.mkdir actual_dir unless Dir.exist? actual_dir
  
  file_and_options = [ {file: 'person.cql', options: {}} ]
  file_and_options.each do |file_and_option|
    cql_file = DG_CQL_DIR + '/' + file_and_option[:file]
    options = file_and_option[:options]
    it "produces the expected DocGraph summary output for #{cql_file}" do
      basename = cql_file.sub(%r{(.*/)?([^/]*).cql\Z}, '\2')
      expected = expected_dir+'/'+basename+'.summary'
      actual = actual_dir+'/'+basename+'.summary'
      begin
        expected_text = File.read(expected)
      rescue Errno::ENOENT => exception
      end

      vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
      vocabulary.finalise
      compositor = ActiveFacts::Compositions::DocGraph.new(vocabulary.constellation, basename, {})
      compositor.generate

      output = ActiveFacts::Generators::Summary.new(compositor.composition, options).generate

      # Save or delete the actual output file:
      if expected_text != output
        File.write(actual, output)
      else
        File.delete(actual) rescue nil
      end

      if expected_text
        expect(output).to be_like(expected_text), "Output #{actual} doesn't match expected #{expected}"
      else
        pending "Actual output in #{actual} can't be compared with missing expected file #{expected}"
        expect(expected_text).to_not be_nil, "I don't know what to expect"
      end
    end
  end
  
end
