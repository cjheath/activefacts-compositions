#
# Test the relational composition from CQL files by comparing generated Datavault summary output
#

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'activefacts/compositions/relational'
require 'activefacts/generator/transgen'
require 'activefacts/input/cql'

TG_CQL_DIR = Pathname.new(__FILE__+'/../cql').relative_path_from(Pathname(Dir.pwd)).to_s
TG_TEST_DIR = Pathname.new(__FILE__+'/..').relative_path_from(Pathname(Dir.pwd)).to_s

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual == expected
  end

  failure_message do
    'Output doesn\'t match expected, see diff'
  end

  diffable
end

describe "Transform generator from CQL" do
  dir = ENV['CQL_DIR'] || TG_CQL_DIR
  actual_dir = (ENV['CQL_DIR'] ? '' : TG_TEST_DIR+'/') + 'actual'
  expected_dir = (ENV['CQL_DIR'] ? '' : TG_TEST_DIR+'/') + 'expected'
  Dir.mkdir actual_dir unless Dir.exist? actual_dir
  
  it "produces the expected Transform Generation output for Null_Person.cql" do
    cql_file = "#{TG_CQL_DIR}/Null_Person.cql"
    options = {}
    expected_file = "#{expected_dir}/Null_Person.cql"
    actual_file = "#{actual_dir}/Null_Person.cql"
    begin
      expected_text = File.read(expected_file)
    rescue Errno::ENOENT => exception
    end

    vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
    vocabulary.finalise
    compositor = ActiveFacts::Compositions::Relational.new(vocabulary.constellation, 'Person', {})
    compositor.generate

    output = ActiveFacts::Generators::TransGen.new(vocabulary.constellation, compositor.composition, options).generate

    File.write(actual_file, output)

    if expected_text
      expect(output).to be_like(expected_text), "Output #{actual_file} doesn't match expected #{expected_file}"
    else
      pending "Actual output in #{actual_file} can't be compared with missing expected file #{expected_file}"
      expect(expected_text).to_not be_nil, "I don't know what to expect"
    end
  end
  
  it "produces the expected Transform Generation output for Staff_Personnel.cql" do
    cql_file = "#{TG_CQL_DIR}/Staff_Personnel.cql"
    options = {}
    expected_file = "#{expected_dir}/Staff_Personnel_gen.cql"
    actual_file = "#{actual_dir}/Staff_Personnel_gen.cql"
    begin
      expected_text = File.read(expected_file)
    rescue Errno::ENOENT => exception
    end

    vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
    vocabulary.finalise
    compositor = ActiveFacts::Compositions::Relational.new(vocabulary.constellation, 'Staff_Personnel', {})
    compositor.generate

    output = ActiveFacts::Generators::TransGen.new(vocabulary.constellation, compositor.composition, options).generate

    File.write(actual_file, output)

    if expected_text
      expect(output).to be_like(expected_text), "Output #{actual_file} doesn't match expected #{expected_file}"
    else
      pending "Actual output in #{actual_file} can't be compared with missing expected file #{expected_file}"
      expect(expected_text).to_not be_nil, "I don't know what to expect"
    end
  end

  it "produces the expected Transform generation output for Staff_Personnel_gen.cql" do
    cql_file = "#{TG_CQL_DIR}/Staff_Personnel_gen.cql"
    options = {}
    expected_file = "#{expected_dir}/Staff_Personnel_gen2.cql"
    actual_file = "#{actual_dir}/Staff_Personnel_gen2.cql"
    begin
      expected_text = File.read(expected_file)
    rescue Errno::ENOENT => exception
    end

    vocabulary = ActiveFacts::Input::CQL.readfile(cql_file)
    vocabulary.finalise
    compositor = ActiveFacts::Compositions::Relational.new(vocabulary.constellation, 'Staff_Personnel_gen', {})
    compositor.generate

    output = ActiveFacts::Generators::TransGen.new(vocabulary.constellation, compositor.composition, options).generate

    File.write(actual_file, output)

    if expected_text
      expect(output).to be_like(expected_text), "Output #{actual_file} doesn't match expected #{expected_file}"
    else
      pending "Actual output in #{actual_file} can't be compared with missing expected file #{expected_file}"
      expect(expected_text).to_not be_nil, "I don't know what to expect"
    end
  end
  
end
