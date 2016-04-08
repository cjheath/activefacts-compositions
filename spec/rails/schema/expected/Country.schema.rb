#
# schema.rb auto-generated for Country
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(:version => 20160408160151) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "countries", :id => false, :force => true do |t|
    t.column "country_id", :primary_key, null: false
    t.column "iso3166_code3", :string, limit: 3, null: false
    t.column "country_name", :string, limit: 60, null: false
    t.column "iso3166_code2", :string, limit: 2, null: false
    t.column "iso3166_numeric3", :integer, null: false
  end

  add_index "countries", ["country_name"], :name => :index_countries_on_country_name, :unique => true
  add_index "countries", ["iso3166_code2"], :name => :index_countries_on_iso3166_code2, :unique => true
  add_index "countries", ["iso3166_code3"], :name => :index_countries_on_iso3166_code3, :unique => true
  add_index "countries", ["iso3166_numeric3"], :name => :index_countries_on_iso3166_numeric3, :unique => true

  unless ENV["EXCLUDE_FKS"]
  end
end
