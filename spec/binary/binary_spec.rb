#
# Test the binary composition from CQL files by comparing specific trace output
#

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

require_relative '../spec_helper'
require 'activefacts/compositions/binary'
require 'activefacts/generator/validate'
require 'activefacts/input/cql'

BINARY_CQL_DIR = Pathname.new(__FILE__+'/../').relative_path_from(Pathname(Dir.pwd)).to_s

# Hack into the tracing mechanism to save the output from the :composition key:
class << trace
  def display key, str
    $trace_output << str+"\n" if key == :composition
  end
end

def generated_trace
  result = $trace_output
  $trace_output = ''
  result
end

def clean_traces
  $trace_output = ''
end

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual == expected
  end

  failure_message do
    'Output doesn\'t match expected, see diff'
  end

  diffable
end

describe "Binary absorption from CQL" do
  dir = ENV['CQL_DIR'] || BINARY_CQL_DIR
  actual_dir = (ENV['CQL_DIR'] ? '' : BINARY_CQL_DIR+'/') + 'actual'
  Dir.mkdir actual_dir unless Dir.exist? actual_dir
  if f = ENV['TEST_FILES']
    files = Dir[dir+"/#{f}*.cql"]
  else
    files = `git ls-files "#{dir}/*.cql"`.split(/\n/)
  end
  files.each do |cql_file|
    expected = cql_file.sub(%r{(.*/)?([^/]*).cql\Z}, dir+'/expected/\2.trc')
    actual = actual_dir + cql_file.sub(%r{(.*/)?([^/]*).cql\Z}, '/\2.trc')
    begin
      expected_text = File.read(expected)
    rescue Errno::ENOENT => exception
    end
    next unless expected_text || ENV['TEST_FILES']

    it "produces the expected binary absorption for #{cql_file}" do
      trace.reinitialize
      clean_traces
      trace.enable :composition

      vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
      vocabulary.finalise
      compositor = ActiveFacts::Compositions::Binary.new(vocabulary.constellation, "test")
      compositor.generate
      output = generated_trace

      # Save or delete the actual output file:
      if expected_text != output
        File.write(actual, output)
      else
        File.delete(actual) rescue nil
      end

      ActiveFacts::Generators::Validate.new(vocabulary.constellation, compositor.composition).generate do |component, problem|
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
