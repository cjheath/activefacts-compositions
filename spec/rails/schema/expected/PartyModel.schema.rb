#
# schema.rb auto-generated for PartyModel
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160802114152) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "companies", id: false, force: true do |t|
    t.column "party_id", :integer, null: false
  end

  create_table "parties", id: false, force: true do |t|
    t.column "party_id", :primary_key, null: false
    t.column "party_type_code", :string, limit: 16, null: false
  end

  create_table "people", id: false, force: true do |t|
    t.column "party_id", :integer, null: false
  end

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :companies, :parties, column: :party_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :people, :parties, column: :party_id, primary_key: :party_id, on_delete: :cascade
  end
end
