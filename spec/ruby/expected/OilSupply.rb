require 'activefacts/api'

module OilSupply
  class ProductName < String
    value_type
  end

  class Product
    identified_by   :product_name
    one_to_one      :product_name, mandatory: true      # Product has Product Name, see ProductName#product
  end

  class Season < String
    value_type      length: 6
  end

  class AcceptableSubstitution
    identified_by   :product, :alternate_product, :season
    has_one         :product, mandatory: true           # Acceptable Substitution involves Product, see Product#all_acceptable_substitution
    has_one         :alternate_product, mandatory: true, class: Product  # Acceptable Substitution involves Product, see Product#all_acceptable_substitution_as_alternate_product
    has_one         :season, mandatory: true            # Acceptable Substitution involves Season, see Season#all_acceptable_substitution
  end

  class Cost < Money
    value_type
  end

  class MonthNr < SignedInteger
    value_type      length: 32
  end

  class Month
    identified_by   :month_nr
    one_to_one      :month_nr, mandatory: true          # Month has Month Nr, see MonthNr#month
    has_one         :season, mandatory: true            # Month is in Season, see Season#all_month
  end

  class Quantity < UnsignedInteger
    value_type      length: 32
  end

  class RefineryName < String
    value_type      length: 80
  end

  class Refinery
    identified_by   :refinery_name
    one_to_one      :refinery_name, mandatory: true     # Refinery has Refinery Name, see RefineryName#refinery
  end

  class YearNr < SignedInteger
    value_type      length: 32
  end

  class Year
    identified_by   :year_nr
    one_to_one      :year_nr, mandatory: true           # Year has Year Nr, see YearNr#year
  end

  class SupplyPeriod
    identified_by   :year, :month
    has_one         :year, mandatory: true              # Supply Period is in Year, see Year#all_supply_period
    has_one         :month, mandatory: true             # Supply Period is in Month, see Month#all_supply_period
  end

  class ProductionForecast
    identified_by   :refinery, :supply_period, :product
    has_one         :refinery, mandatory: true          # Production Forecast involves Refinery, see Refinery#all_production_forecast
    has_one         :supply_period, mandatory: true     # Production Forecast involves Supply Period, see SupplyPeriod#all_production_forecast
    has_one         :product, mandatory: true           # Production Forecast involves Product, see Product#all_production_forecast
    has_one         :quantity, mandatory: true          # Production Forecast involves Quantity, see Quantity#all_production_forecast
    has_one         :cost                               # Production Forecast predicts Cost, see Cost#all_production_forecast
  end

  class RegionName < String
    value_type
  end

  class Region
    identified_by   :region_name
    one_to_one      :region_name, mandatory: true       # Region has Region Name, see RegionName#region
  end

  class RegionalDemand
    identified_by   :region, :supply_period, :product
    has_one         :region, mandatory: true            # Regional Demand involves Region, see Region#all_regional_demand
    has_one         :supply_period, mandatory: true     # Regional Demand involves Supply Period, see SupplyPeriod#all_regional_demand
    has_one         :product, mandatory: true           # Regional Demand involves Product, see Product#all_regional_demand
    has_one         :quantity, mandatory: true          # Regional Demand involves Quantity, see Quantity#all_regional_demand
  end

  class TransportMethod < String
    value_type
  end

  class TransportRoute
    identified_by   :transport_method, :refinery, :region
    has_one         :transport_method, mandatory: true  # Transport Route involves Transport Method, see TransportMethod#all_transport_route
    has_one         :refinery, mandatory: true          # Transport Route involves Refinery, see Refinery#all_transport_route
    has_one         :region, mandatory: true            # Transport Route involves Region, see Region#all_transport_route
    has_one         :cost                               # Transport Route incurs Cost per kl, see Cost#all_transport_route
  end
end