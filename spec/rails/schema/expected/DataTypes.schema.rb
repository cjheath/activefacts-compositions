#
# Auto-generated (edits will be lost) using:
# rspec spec/rails/models/models_spec.rb spec/rails/schema/schema_spec.rb
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20000000000000) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "aac_ets", id: false, force: true do |t|
    t.column "alternate_auto_counter", :primary_key, null: false
  end

  create_table "aac_subs", id: false, force: true do |t|
    t.column "aac_et_alternate_auto_counter", :integer, null: false
  end

  create_table "ag_ets", id: false, force: true do |t|
    t.column "alternate_guid", :uuid, default: 'gen_random_uuid()', primary_key: true, null: false
  end

  create_table "ag_subs", id: false, force: true do |t|
    t.column "ag_et_alternate_guid", :uuid, null: false
  end

  create_table "containers", id: false, force: true do |t|
    t.column "container_id", :primary_key, null: false
    t.column "container_name", :string, null: false
    t.column "alternate_auto_counter", :integer, null: false
    t.column "alternate_auto_time_stamp", :datetime, null: false
    t.column "alternate_big_int", :integer, null: false
    t.column "alternate_bit", :boolean, null: false
    t.column "alternate_character", :string, null: false
    t.column "alternate_currency", :decimal, null: false
    t.column "alternate_date_time", :datetime, null: false
    t.column "alternate_double", :float, null: false
    t.column "alternate_fixed_length_text", :string, null: false
    t.column "alternate_float", :float, null: false
    t.column "alternate_guid", :uuid, null: false
    t.column "alternate_int", :integer, null: false
    t.column "alternate_large_length_text", :text, null: false
    t.column "alternate_national_character", :string, null: false
    t.column "alternate_national_character_varying", :string, null: false
    t.column "alternate_nchar", :string, null: false
    t.column "alternate_nvarchar", :string, null: false
    t.column "alternate_picture_raw_data", :binary, null: false
    t.column "alternate_signed_int", :integer, null: false
    t.column "alternate_signed_integer", :integer, null: false
    t.column "alternate_small_int", :integer, null: false
    t.column "alternate_time_stamp", :datetime, null: false
    t.column "alternate_tiny_int", :integer, null: false
    t.column "alternate_unsigned", :integer, null: false
    t.column "alternate_unsigned_int", :integer, null: false
    t.column "alternate_unsigned_integer", :integer, null: false
    t.column "alternate_varchar", :string, null: false
    t.column "alternate_variable_length_raw_data", :binary, null: false
    t.column "alternate_variable_length_text", :string, null: false
    t.column "byte", :integer, null: false
    t.column "char8", :string, limit: 8, null: false
    t.column "decimal14", :decimal, precision: 14, null: false
    t.column "decimal14__6", :decimal, precision: 14, scale: 6, null: false
    t.column "decimal8__3", :decimal, precision: 8, scale: 3, null: false
    t.column "fundamental_binary", :binary, null: false
    t.column "fundamental_boolean", :boolean, null: false
    t.column "fundamental_char", :string, null: false
    t.column "fundamental_date", :datetime, null: false
    t.column "fundamental_date_time", :datetime, null: false
    t.column "fundamental_decimal", :decimal, null: false
    t.column "fundamental_integer", :integer, null: false
    t.column "fundamental_money", :decimal, null: false
    t.column "fundamental_real", :float, null: false
    t.column "fundamental_string", :string, null: false
    t.column "fundamental_text", :text, null: false
    t.column "fundamental_time", :time, null: false
    t.column "fundamental_timestamp", :datetime, null: false
    t.column "int", :integer, null: false
    t.column "int16", :integer, null: false
    t.column "int32", :integer, null: false
    t.column "int64", :integer, null: false
    t.column "int8", :integer, null: false
    t.column "int80", :integer, null: false
    t.column "large", :integer, null: false
    t.column "quad", :integer, null: false
    t.column "real32", :float, null: false
    t.column "real64", :float, null: false
    t.column "real80", :float, null: false
    t.column "string255", :string, limit: 255, null: false
    t.column "text65536", :text, null: false
    t.column "u_byte", :integer, null: false
    t.column "u_int", :integer, null: false
    t.column "u_large", :integer, null: false
    t.column "u_quad", :integer, null: false
    t.column "u_word", :integer, null: false
    t.column "word", :integer, null: false
  end

  add_index "containers", ["container_name"], name: :index_containers_on_container_name, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :aac_subs, :aac_ets, column: :aac_et_alternate_auto_counter, primary_key: :alternate_auto_counter, on_delete: :cascade
    add_foreign_key :ag_subs, :ag_ets, column: :ag_et_alternate_guid, primary_key: :alternate_guid, on_delete: :cascade
  end
end
