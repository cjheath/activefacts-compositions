require 'activefacts/api'

module PartyModel
  class Party
    identified_by   :party_id
    one_to_one      :party_id, mandatory: true, class: "PartyID"  # Party has Party ID, see PartyID#party_as_party_id
    has_one         :party_type, mandatory: true        # Party is of Party Type, see PartyType#all_party
  end

  class Company < Party
  end

  class ID < AutoCounter
    value_type
  end

  class PartyID < ID
    value_type
  end

  class PartyTypeCode < String
    value_type      length: 16
  end

  class PartyType
    identified_by   :party_type_code
    one_to_one      :party_type_code, mandatory: true   # Party Type has Party Type Code, see PartyTypeCode#party_type
  end

  class Person < Party
  end

  class TeachingInstitution < Company
  end

  class RTO < TeachingInstitution
  end

  class SuperannuationCompany < Company
  end

  class User < Person
  end
end
