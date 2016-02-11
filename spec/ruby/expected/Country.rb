require 'activefacts/api'

module Country
  class CountryName < String
    value_type      length: 60
  end

  class ISO3166Code2 < String
    value_type      length: 2
  end

  class ISO3166Code3 < String
    value_type      length: 3
  end

  class ISO3166Numeric3 < Integer
    value_type
  end

  class Country
    identified_by   :iso3166_code3
    one_to_one      :iso3166_code3, mandatory: true     # Country has ISO3166Code3, see ISO3166Code3#country
    one_to_one      :country_name, mandatory: true      # Country is called Country Name, see CountryName#country
    one_to_one      :iso3166_code2, mandatory: true     # Country has ISO3166Code2, see ISO3166Code2#country
    one_to_one      :iso3166_numeric3, mandatory: true  # Country has ISO3166Numeric3, see ISO3166Numeric3#country
  end
end
