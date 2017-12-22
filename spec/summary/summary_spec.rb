#
# Test the relational composition from CQL files by comparing summary output
#

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'spec_helper'
require 'activefacts/compositions/relational'
require 'activefacts/generator/validate'
require 'activefacts/generator/summary'
require 'activefacts/input/cql'

SUMMARY_CQL_DIR = Pathname.new(__FILE__+'/../../cql').relative_path_from(Pathname(Dir.pwd)).to_s
SUMMARY_TEST_DIR = Pathname.new(__FILE__+'/..').relative_path_from(Pathname(Dir.pwd)).to_s

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual == expected
  end

  failure_message do
    'Output doesn\'t match expected, see diff'
  end

  diffable
end

describe "Summary of absorption from CQL" do
  dir = ENV['CQL_DIR'] || SUMMARY_CQL_DIR
  actual_dir = (ENV['CQL_DIR'] ? '' : SUMMARY_TEST_DIR+'/') + 'actual'
  expected_dir = (ENV['CQL_DIR'] ? '' : SUMMARY_TEST_DIR+'/') + 'expected'
  Dir.mkdir actual_dir unless Dir.exist? actual_dir
  if f = ENV['TEST_FILES']
    files = Dir[dir+"/#{f}*.cql"]
  else
    files = `git ls-files "#{dir}/*.cql"`.split(/\n/)
  end
  files.each do |cql_file|
    expected = cql_file.sub(%r{(.*/)?([^/]*).cql\Z}, expected_dir+'/\2.trc')
    actual = cql_file.sub(%r{(.*/)?([^/]*).cql\Z}, actual_dir+'/\2.trc')
    begin
      expected_text = File.read(expected)
    rescue Errno::ENOENT => exception
    end
    next unless expected_text || ENV['TEST_FILES']

    it "produces the expected relational absorption for #{cql_file}" do
      trace.reinitialize

      vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
      vocabulary.finalise
      compositor = ActiveFacts::Compositions::Relational.new(vocabulary.constellation, "test")
      compositor.generate
      output = compositor.composition.summary

      # Save or delete the actual output file:
      if expected_text != output
        File.write(actual, output)
      else
        File.delete(actual) rescue nil
      end

      ActiveFacts::Generators::Validate.new(compositor.composition).generate do |component, problem|
        expect("#{component.inspect}: #{problem}").to be_nil
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
