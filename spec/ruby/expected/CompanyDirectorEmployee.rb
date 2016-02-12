require 'activefacts/api'

module CompanyDirectorEmployee
  class CompanyName < String
    value_type      length: 48
  end

  class Company
    identified_by   :company_name
    one_to_one      :company_name, mandatory: true      # Company is called Company Name, see CompanyName#company
    maybe           :is_listed                          # Is Listed
  end

  class Date < ::Date
    value_type
  end

  class Meeting
    identified_by   :company, :date, :is_board_meeting
    has_one         :company, mandatory: true           # Meeting is held by Company, see Company#all_meeting
    has_one         :date, mandatory: true              # Meeting is held on Date, see Date#all_meeting
    maybe           :is_board_meeting                   # Is Board Meeting
  end

  class Name < String
    value_type      length: 48
  end

  class Person
    identified_by   :given_name, :family_name
    has_one         :given_name, mandatory: true, class: Name  # Person has given-Name, see Name#all_person_as_given_name
    has_one         :family_name, class: Name           # Person is called family-Name, see Name#all_person_as_family_name
    has_one         :birth_date, class: Date            # Person was born on birth-Date, see Date#all_person_as_birth_date
  end

  class Attendance
    identified_by   :attendee, :meeting
    has_one         :attendee, mandatory: true, class: Person  # Attendance involves Person, see Person#all_attendance_as_attendee
    has_one         :meeting, mandatory: true           # Attendance involves Meeting, see Meeting#all_attendance
  end

  class Directorship
    identified_by   :director, :company
    has_one         :director, mandatory: true, class: Person  # Directorship involves Person, see Person#all_directorship_as_director
    has_one         :company, mandatory: true           # Directorship involves Company, see Company#all_directorship
    has_one         :appointment_date, mandatory: true, class: Date  # Directorship began on appointment-Date, see Date#all_directorship_as_appointment_date
  end

  class EmployeeNr < SignedInteger
    value_type      length: 32
  end

  class Manager < Employee
    maybe           :is_ceo                             # Is Ceo
  end

  class Employee
    identified_by   :employee_nr
    one_to_one      :employee_nr, mandatory: true       # Employee has Employee Nr, see EmployeeNr#employee
    has_one         :company, mandatory: true           # Employee works at Company, see Company#all_employee
    has_one         :manager                            # Employee is supervised by Manager, see Manager#all_employee
  end

  class Employment
    identified_by   :person, :employee
    has_one         :person, mandatory: true            # Employment involves Person, see Person#all_employment
    has_one         :employee, mandatory: true          # Employment involves Employee, see Employee#all_employment
  end
end
