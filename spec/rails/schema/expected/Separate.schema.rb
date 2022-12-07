#
# Auto-generated (edits will be lost)
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20000000000000) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "bases", id: false, force: true do |t|
    t.column "base_guid", :uuid, default: 'gen_random_uuid()', primary_key: true, null: false
    t.column "base_val", :Val, null: false
  end

  create_table "partitions", id: false, force: true do |t|
    t.column "base_guid", :uuid, default: 'gen_random_uuid()', primary_key: true, null: false
    t.column "base_val", :Val, null: false
    t.column "part_val", :Val, null: false
  end

  create_table "partition_inds", id: false, force: true do |t|
    t.column "partition_ind_id", :primary_key, null: false
    t.column "base_guid", :uuid, null: false
    t.column "base_val", :Val, null: false
    t.column "partition_ind_key", :uuid, null: false
    t.column "absorbed_part_abs_part_val", :Val, null: true
  end

  add_index "partition_inds", ["base_guid"], name: :index_partition_inds_on_base_guid, unique: true
  add_index "partition_inds", ["partition_ind_key"], name: :index_partition_inds_on_partition_ind_key, unique: true

  create_table "separates", id: false, force: true do |t|
    t.column "base_guid", :uuid, null: false
    t.column "sep_val", :Val, null: false
  end

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :separates, :bases, column: :base_guid, primary_key: :base_guid, on_delete: :cascade
  end
end
