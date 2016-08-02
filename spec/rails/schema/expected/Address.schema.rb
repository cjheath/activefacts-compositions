#
# schema.rb auto-generated for Address
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160802114145) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "companies", id: false, force: true do |t|
    t.column "company_id", :primary_key, null: false
    t.column "company_name", :string, null: false
    t.column "address_street_number", :string, limit: 12, null: true
    t.column "address_street_first_street_line", :string, limit: 64, null: true
    t.column "address_street_second_street_line", :string, limit: 64, null: true
    t.column "address_street_third_street_line", :string, limit: 64, null: true
    t.column "address_city", :string, limit: 64, null: true
    t.column "address_postcode", :string, null: true
  end

  add_index "companies", ["company_name"], name: :index_companies_on_company_name, unique: true

  create_table "people", id: false, force: true do |t|
    t.column "person_id", :primary_key, null: false
    t.column "family_name", :string, limit: 20, null: false
    t.column "given_names", :string, limit: 20, null: false
    t.column "address_street_number", :string, limit: 12, null: true
    t.column "address_street_first_street_line", :string, limit: 64, null: true
    t.column "address_street_second_street_line", :string, limit: 64, null: true
    t.column "address_street_third_street_line", :string, limit: 64, null: true
    t.column "address_city", :string, limit: 64, null: true
    t.column "address_postcode", :string, null: true
  end

  add_index "people", ["family_name", "given_names"], name: :index_people_on_family_name_given_names, unique: true

  unless ENV["EXCLUDE_FKS"]
  end
end
