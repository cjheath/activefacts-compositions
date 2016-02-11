require 'activefacts/api'

module Address
  class City < String
    value_type      length: 64
  end

  class Number < String
    value_type      length: 12
  end

  class Postcode < String
    value_type
  end

  class StreetLine < String
    value_type      length: 64
  end

  class Street
    identified_by   :first_street_line, :second_street_line, :third_street_line
    has_one         :first_street_line, mandatory: true, class: StreetLine  # Street includes first-Street Line, see StreetLine#all_street_as_first_street_line
    has_one         :second_street_line, class: StreetLine  # Street includes second-Street Line, see StreetLine#all_street_as_second_street_line
    has_one         :third_street_line, class: StreetLine  # Street includes third-Street Line, see StreetLine#all_street_as_third_street_line
  end

  class Address
    identified_by   :street_number, :street, :city, :postcode
    has_one         :street_number, class: Number       # Address is at street-Number, see Number#all_address_as_street_number
    has_one         :street, mandatory: true            # Address is at Street, see Street#all_address
    has_one         :city, mandatory: true              # Address is in City, see City#all_address
    has_one         :postcode                           # Address is in Postcode, see Postcode#all_address
  end

  class CompanyName < String
    value_type
  end

  class Company
    identified_by   :company_name
    one_to_one      :company_name, mandatory: true      # Company has Company Name, see CompanyName#company
    has_one         :address                            # Company has head office at Address, see Address#all_company
  end

  class FamilyName < String
    value_type      length: 20
  end

  class Family
    identified_by   :family_name
    one_to_one      :family_name, mandatory: true       # Family has Family Name, see FamilyName#family
  end

  class GivenNames < String
    value_type      length: 20
  end

  class Person
    identified_by   :family, :given_names
    has_one         :family, mandatory: true            # Person is of Family, see Family#all_person
    has_one         :given_names, mandatory: true       # Person has Given Names, see GivenNames#all_person
    has_one         :address                            # Person lives at Address, see Address#all_person
  end
end