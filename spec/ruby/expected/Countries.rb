require 'activefacts/api'

module Countries
  class CountryCode < Char
    value_type      length: 3
  end

  class Country
    identified_by   :country_code
    one_to_one      :country_code, mandatory: true      # Country has Country Code, see CountryCode#country
  end
end
