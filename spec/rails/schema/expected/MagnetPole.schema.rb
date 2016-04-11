#
# schema.rb auto-generated for MagnetPole
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160411150449) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "magnets", id: false, force: true do |t|
    t.column "magnet_auto_counter", :primary_key, null: false
  end

  create_table "magnet_poles", id: false, force: true do |t|
    t.column "magnet_pole_id", :primary_key, null: false
    t.column "magnet_auto_counter", :integer, null: false
    t.column "is_north", :boolean, null: true
  end

  add_index "magnet_poles", ["magnet_auto_counter", "is_north"], name: :index_magnet_poles_on_magnet_auto_counter_is_north, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :magnet_poles, :magnet, column: :magnet_auto_counter, primary_key: :magnet_auto_counter, on_delete: :cascade
    add_index :magnet_poles, [:magnet_auto_counter], unique: false, name: :index_magnet_poles_on_magnet_auto_counter
  end
end
