#
# schema.rb auto-generated for FKProb
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160411150445) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "ots", id: false, force: true do |t|
    t.column "ot_id", :primary_key, null: false
    t.column "name", :string, null: false
  end

  add_index "ots", ["name"], name: :index_ots_on_name, unique: true

  create_table "vtps", id: false, force: true do |t|
    t.column "vtp_id", :primary_key, null: false
    t.column "vt_ot_id", :integer, null: false
    t.column "name", :string, null: false
  end

  add_index "vtps", ["vt_ot_id", "name"], name: :index_vtps_on_vt_ot_id_name, unique: true

  create_table "vtp_restrictions", id: false, force: true do |t|
    t.column "vt_ot_id", :integer, null: false
    t.column "vtp_id", :integer, null: false
  end

  add_index "vtp_restrictions", ["vt_ot_id", "vtp_id"], name: :index_vtp_restrictions_on_vt_ot_id_vtp_id, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :vtp_restrictions, :ot, column: :vt_ot_id, primary_key: :ot_id, on_delete: :cascade
    add_foreign_key :vtp_restrictions, :vtp, column: :vtp_id, primary_key: :vtp_id, on_delete: :cascade
    add_foreign_key :vtps, :ot, column: :vt_ot_id, primary_key: :ot_id, on_delete: :cascade
    add_index :vtp_restrictions, [:vt_ot_id], unique: false, name: :index_vtp_restrictions_on_vt_ot_id
    add_index :vtp_restrictions, [:vtp_id], unique: false, name: :index_vtp_restrictions_on_vtp_id
    add_index :vtps, [:vt_ot_id], unique: false, name: :index_vtps_on_vt_ot_id
  end
end
