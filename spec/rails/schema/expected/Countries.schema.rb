#
# schema.rb auto-generated for Countries
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(:version => 20160408160151) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "countries", :id => false, :force => true do |t|
    t.column "country_code_id", :integer, null: false
  end

  add_index "countries", ["country_code", "country_code_id"], :name => :index_countries_on_country_code_country_code_id, :unique => true

  create_table "country_codes", :id => false, :force => true do |t|
    t.column "country_code_id", :primary_key, null: false
    t.column "country_code_value", :string, limit: 3, null: false
  end

  add_index "country_codes", ["country_code_value"], :name => :index_country_codes_on_country_code_value, :unique => true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :countries, :country_code, :column => :country_code_id, :primary_key => :country_code_id, :on_delete => :cascade
  end
end
