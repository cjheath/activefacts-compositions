#
# schema.rb auto-generated for OilSupply
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160802181213) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "acceptable_substitutions", id: false, force: true do |t|
    t.column "acceptable_substitution_id", :primary_key, null: false
    t.column "product_id", :integer, null: false
    t.column "alternate_product_id", :integer, null: false
    t.column "season", :string, limit: 6, null: false
  end

  add_index "acceptable_substitutions", ["product_id", "alternate_product_id", "season"], name: :index_acceptable_substitutions_on_product_id_alternat__3906fbaf, unique: true

  create_table "months", id: false, force: true do |t|
    t.column "month_id", :primary_key, null: false
    t.column "month_nr", :integer, null: false
    t.column "season", :string, limit: 6, null: false
  end

  add_index "months", ["month_nr"], name: :index_months_on_month_nr, unique: true

  create_table "products", id: false, force: true do |t|
    t.column "product_id", :primary_key, null: false
    t.column "product_name", :string, null: false
  end

  add_index "products", ["product_name"], name: :index_products_on_product_name, unique: true

  create_table "production_forecasts", id: false, force: true do |t|
    t.column "production_forecast_id", :primary_key, null: false
    t.column "refinery_id", :integer, null: false
    t.column "supply_period_id", :integer, null: false
    t.column "product_id", :integer, null: false
    t.column "quantity", :integer, null: false
    t.column "cost", :decimal, null: true
  end

  add_index "production_forecasts", ["refinery_id", "supply_period_id", "product_id"], name: :index_production_forecasts_on_refinery_id_supply_peri__a385e824, unique: true

  create_table "refineries", id: false, force: true do |t|
    t.column "refinery_id", :primary_key, null: false
    t.column "refinery_name", :string, limit: 80, null: false
  end

  add_index "refineries", ["refinery_name"], name: :index_refineries_on_refinery_name, unique: true

  create_table "regions", id: false, force: true do |t|
    t.column "region_id", :primary_key, null: false
    t.column "region_name", :string, null: false
  end

  add_index "regions", ["region_name"], name: :index_regions_on_region_name, unique: true

  create_table "regional_demands", id: false, force: true do |t|
    t.column "regional_demand_id", :primary_key, null: false
    t.column "region_id", :integer, null: false
    t.column "supply_period_id", :integer, null: false
    t.column "product_id", :integer, null: false
    t.column "quantity", :integer, null: false
  end

  add_index "regional_demands", ["region_id", "supply_period_id", "product_id"], name: :index_regional_demands_on_region_id_supply_period_id_product_id, unique: true

  create_table "supply_periods", id: false, force: true do |t|
    t.column "supply_period_id", :primary_key, null: false
    t.column "year_nr", :integer, null: false
    t.column "month_id", :integer, null: false
  end

  add_index "supply_periods", ["year_nr", "month_id"], name: :index_supply_periods_on_year_nr_month_id, unique: true

  create_table "transport_routes", id: false, force: true do |t|
    t.column "transport_route_id", :primary_key, null: false
    t.column "transport_method", :string, null: false
    t.column "refinery_id", :integer, null: false
    t.column "region_id", :integer, null: false
    t.column "cost", :decimal, null: true
  end

  add_index "transport_routes", ["transport_method", "refinery_id", "region_id"], name: :index_transport_routes_on_transport_method_refinery_i__bb1e6e85, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :acceptable_substitutions, :products, column: :alternate_product_id, primary_key: :product_id, on_delete: :cascade
    add_foreign_key :acceptable_substitutions, :products, column: :product_id, primary_key: :product_id, on_delete: :cascade
    add_foreign_key :production_forecasts, :products, column: :product_id, primary_key: :product_id, on_delete: :cascade
    add_foreign_key :production_forecasts, :refineries, column: :refinery_id, primary_key: :refinery_id, on_delete: :cascade
    add_foreign_key :production_forecasts, :supply_periods, column: :supply_period_id, primary_key: :supply_period_id, on_delete: :cascade
    add_foreign_key :regional_demands, :products, column: :product_id, primary_key: :product_id, on_delete: :cascade
    add_foreign_key :regional_demands, :regions, column: :region_id, primary_key: :region_id, on_delete: :cascade
    add_foreign_key :regional_demands, :supply_periods, column: :supply_period_id, primary_key: :supply_period_id, on_delete: :cascade
    add_foreign_key :supply_periods, :months, column: :month_id, primary_key: :month_id, on_delete: :cascade
    add_foreign_key :transport_routes, :refineries, column: :refinery_id, primary_key: :refinery_id, on_delete: :cascade
    add_foreign_key :transport_routes, :regions, column: :region_id, primary_key: :region_id, on_delete: :cascade
    add_index :acceptable_substitutions, [:alternate_product_id], unique: false, name: :index_acceptable_substitutions_on_alternate_product_id
    add_index :acceptable_substitutions, [:product_id], unique: false, name: :index_acceptable_substitutions_on_product_id
    add_index :production_forecasts, [:product_id], unique: false, name: :index_production_forecasts_on_product_id
    add_index :production_forecasts, [:refinery_id], unique: false, name: :index_production_forecasts_on_refinery_id
    add_index :production_forecasts, [:supply_period_id], unique: false, name: :index_production_forecasts_on_supply_period_id
    add_index :regional_demands, [:product_id], unique: false, name: :index_regional_demands_on_product_id
    add_index :regional_demands, [:region_id], unique: false, name: :index_regional_demands_on_region_id
    add_index :regional_demands, [:supply_period_id], unique: false, name: :index_regional_demands_on_supply_period_id
    add_index :supply_periods, [:month_id], unique: false, name: :index_supply_periods_on_month_id
    add_index :transport_routes, [:refinery_id], unique: false, name: :index_transport_routes_on_refinery_id
    add_index :transport_routes, [:region_id], unique: false, name: :index_transport_routes_on_region_id
  end
end
