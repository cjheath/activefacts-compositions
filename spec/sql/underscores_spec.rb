require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'spec_helper'
require 'activefacts/compositions/relational'
require 'activefacts/compositions/names'
require 'activefacts/generator/sql'
require 'activefacts/input/cql'

SQL_CQL_DIR ||= Pathname.new(__FILE__+'/../../cql').relative_path_from(Pathname(Dir.pwd)).to_s

describe "SQL schema from CQL" do
  context "underscores as word separator" do
    it 'should generate schema with underscores in table names and field names' do
      vocabulary = ActiveFacts::Input::CQL.readfile(SQL_CQL_DIR + '/MagnetPole.cql')
      vocabulary.finalise
      compositor = ActiveFacts::Compositions::Relational.new(vocabulary.constellation, "test")
      compositor.generate

      output = ActiveFacts::Generators::SQL.new(vocabulary.constellation, compositor.composition, {'columns' => 'snake'}).generate
      expect(output).to eq <<EOS
CREATE TABLE Magnet (
	-- Magnet has Magnet AutoCounter
	magnet_auto_counter                     BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Magnet(Magnet AutoCounter in "Magnet has Magnet AutoCounter")
	PRIMARY KEY(magnet_auto_counter)
);


CREATE TABLE MagnetPole (
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	magnet_auto_counter                     BIGINT NOT NULL,
	-- MagnetPole Is North
	is_north                                BOOLEAN,
	-- Primary index to MagnetPole(Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north")
	PRIMARY KEY(magnet_auto_counter, is_north),
	FOREIGN KEY (magnet_auto_counter) REFERENCES Magnet (magnet_auto_counter)
);


EOS

    end
  end


end
