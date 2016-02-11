require 'activefacts/api'

module Person
  class Name < String
    value_type
  end

  class Person
    identified_by   :family_name, :given_name
    has_one         :family_name, mandatory: true, class: Name  # Person has family-Name, see Name#all_person_as_family_name
    has_one         :given_name, mandatory: true, class: Name  # Person has given-Name, see Name#all_person_as_given_name
  end
end
