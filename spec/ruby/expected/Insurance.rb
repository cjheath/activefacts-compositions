require 'activefacts/api'

module Insurance
  class City < String
    value_type
  end

  class Postcode < String
    value_type
  end

  class StateCode < UnsignedInteger
    value_type      length: 8
  end

  class StateName < String
    value_type      length: 256
  end

  class State
    identified_by   :state_code
    one_to_one      :state_code, mandatory: true        # State has State Code, see StateCode#state
    one_to_one      :state_name                         # State has State Name, see StateName#state
  end

  class Street < String
    value_type      length: 256
  end

  class Address
    identified_by   :street, :city, :postcode, :state
    has_one         :street, mandatory: true            # Address is at Street, see Street#all_address
    has_one         :city, mandatory: true              # Address is in City, see City#all_address
    has_one         :postcode                           # Address is in Postcode, see Postcode#all_address
    has_one         :state                              # Address is in State, see State#all_address
  end

  class Alias < Char
    value_type      length: 3
  end

  class ApplicationNr < SignedInteger
    value_type      length: 32
  end

  class Application
    identified_by   :application_nr
    one_to_one      :application_nr, mandatory: true    # Application has Application Nr, see ApplicationNr#application
  end

  class Party
    identified_by   :party_id
    one_to_one      :party_id, mandatory: true, class: "PartyID"  # Party has Party ID, see PartyID#party_as_party_id
    maybe           :is_a_company                       # Is A Company
    has_one         :postal_address, class: Address     # Party has postal-Address, see Address#all_party_as_postal_address
  end

  class Company < Party
    has_one         :contact_person, mandatory: true, class: "Person"  # Company has contact-Person, see Person#all_company_as_contact_person
  end

  class Contractor < Company
  end

  class Assessor < Contractor
  end

  class AssetID < AutoCounter
    value_type
  end

  class Asset
    identified_by   :asset_id
    one_to_one      :asset_id, mandatory: true, class: AssetID  # Asset has Asset ID, see AssetID#asset_as_asset_id
  end

  class AuthorisedRep < Party
  end

  class Badge < String
    value_type
  end

  class Charge < String
    value_type
  end

  class ClaimID < AutoCounter
    value_type
  end

  class ClaimSequence < UnsignedInteger
    value_type      length: 32
  end

  class ITCClaimed < Decimal
    value_type      length: 18
  end

  class Insured < Party
  end

  class PolicySerial < UnsignedInteger
    value_type      length: 32
  end

  class Description < String
    value_type      length: 1024
  end

  class ProductCode < UnsignedInteger
    value_type      length: 8
  end

  class Product
    identified_by   :product_code
    one_to_one      :product_code, mandatory: true      # Product has Product Code, see ProductCode#product
    one_to_one      :alias                              # Product has Alias, see Alias#product
    one_to_one      :description                        # Product has Description, see Description#product
  end

  class YearNr < SignedInteger
    value_type      length: 32
  end

  class Year
    identified_by   :year_nr
    one_to_one      :year_nr, mandatory: true           # Year has Year Nr, see YearNr#year
  end

  class Policy
    identified_by   :p_year, :p_product, :p_state, :p_serial
    has_one         :p_year, mandatory: true, class: Year  # Policy was issued in p_year, see Year#all_policy_as_p_year
    has_one         :p_product, mandatory: true, class: Product  # Policy is for product having p_product, see Product#all_policy_as_p_product
    has_one         :p_state, mandatory: true, class: State  # Policy issued in state having p_state, see State#all_policy_as_p_state
    has_one         :p_serial, mandatory: true, class: PolicySerial  # Policy has p_serial, see PolicySerial#all_policy_as_p_serial
    has_one         :application, mandatory: true       # Policy has Application, see Application#all_policy
    has_one         :insured, mandatory: true           # Policy belongs to Insured, see Insured#all_policy
    has_one         :authorised_rep                     # Policy was sold by Authorised Rep, see AuthorisedRep#all_policy
    has_one         :itc_claimed, class: ITCClaimed     # Policy has ITC Claimed, see ITCClaimed#all_policy_as_itc_claimed
  end

  class Claim
    identified_by   :claim_id
    one_to_one      :claim_id, mandatory: true, class: ClaimID  # Claim has Claim ID, see ClaimID#claim_as_claim_id
    has_one         :p_sequence, mandatory: true, class: ClaimSequence  # Claim has p_sequence, see ClaimSequence#all_claim_as_p_sequence
    has_one         :policy, mandatory: true            # Claim is on Policy, see Policy#all_claim
  end

  class Colour < String
    value_type
  end

  class ContactMethod < Char
    value_type      length: 1
  end

  class Email < String
    value_type
  end

  class Date < ::Date
    value_type
  end

  class Name < String
    value_type      length: 256
  end

  class Occupation < String
    value_type
  end

  class Title < String
    value_type
  end

  class Person < Party
    has_one         :family_name, mandatory: true, class: Name  # Person has family-Name, see Name#all_person_as_family_name
    has_one         :given_name, mandatory: true, class: Name  # Person has given-Name, see Name#all_person_as_given_name
    has_one         :title, mandatory: true             # Person has Title, see Title#all_person
    has_one         :address                            # Person lives at Address, see Address#all_person
    has_one         :birth_date, class: Date            # Person has birth-Date, see Date#all_person_as_birth_date
    has_one         :occupation                         # Person has Occupation, see Occupation#all_person
  end

  class PhoneNr < String
    value_type
  end

  class Phone
    identified_by   :phone_nr
    one_to_one      :phone_nr, mandatory: true          # Phone has Phone Nr, see PhoneNr#phone
  end

  class Time < ::Time
    value_type
  end

  class ContactMethods
    identified_by   :person
    one_to_one      :person, mandatory: true            # Contact Methods are for Person, see Person#contact_methods
    has_one         :business_phone, class: Phone       # Contact Methods includes business-Phone, see Phone#all_contact_methods_as_business_phone
    has_one         :contact_time, class: Time          # Contact Methods prefers contact-Time, see Time#all_contact_methods_as_contact_time
    has_one         :email                              # Contact Methods includes Email, see Email#all_contact_methods
    has_one         :home_phone, class: Phone           # Contact Methods includes home-Phone, see Phone#all_contact_methods_as_home_phone
    has_one         :mobile_phone, class: Phone         # Contact Methods includes mobile-Phone, see Phone#all_contact_methods_as_mobile_phone
    has_one         :preferred_contact_method, class: ContactMethod  # Contact Methods has preferred-Contact Method, see ContactMethod#all_contact_methods_as_preferred_contact_method
  end

  class ContractorAppointment
    identified_by   :claim, :contractor
    has_one         :claim, mandatory: true             # Contractor Appointment involves Claim, see Claim#all_contractor_appointment
    has_one         :contractor, mandatory: true        # Contractor Appointment involves Contractor, see Contractor#all_contractor_appointment
  end

  class Count < UnsignedInteger
    value_type      length: 32
  end

  class CoverTypeCode < Char
    value_type
  end

  class CoverTypeName < String
    value_type
  end

  class CoverType
    identified_by   :cover_type_code
    one_to_one      :cover_type_code, mandatory: true   # Cover Type has Cover Type Code, see CoverTypeCode#cover_type
    one_to_one      :cover_type_name, mandatory: true   # Cover Type has Cover Type Name, see CoverTypeName#cover_type
  end

  class Cover
    identified_by   :policy, :cover_type, :asset
    has_one         :policy, mandatory: true            # Cover involves Policy, see Policy#all_cover
    has_one         :cover_type, mandatory: true        # Cover involves Cover Type, see CoverType#all_cover
    has_one         :asset, mandatory: true             # Cover involves Asset, see Asset#all_cover
  end

  class PolicyWordingText < String
    value_type
  end

  class PolicyWording
    identified_by   :policy_wording_text
    one_to_one      :policy_wording_text, mandatory: true  # Policy Wording has Policy Wording Text, see PolicyWordingText#policy_wording
  end

  class CoverWording
    identified_by   :cover_type, :policy_wording, :start_date
    has_one         :cover_type, mandatory: true        # Cover Wording involves Cover Type, see CoverType#all_cover_wording
    has_one         :policy_wording, mandatory: true    # Cover Wording involves Policy Wording, see PolicyWording#all_cover_wording
    has_one         :start_date, mandatory: true, class: Date  # Cover Wording involves Date, see Date#all_cover_wording_as_start_date
  end

  class DateTime < ::DateTime
    value_type
  end

  class Dealer < Party
  end

  class Intoxication < String
    value_type
  end

  class Reason < String
    value_type
  end

  class TestResult < String
    value_type
  end

  class Incident
    identified_by   :claim
    one_to_one      :claim, mandatory: true             # Incident is of Claim, see Claim#incident
    has_one         :address, mandatory: true           # Incident relates to loss at Address, see Address#all_incident
    has_one         :date_time, mandatory: true         # Incident relates to loss on Date Time, see DateTime#all_incident
  end

  class Location < String
    value_type
  end

  class LiabilityCode < Char
    value_type      length: 1
  end

  class Liability
    identified_by   :liability_code
    one_to_one      :liability_code, mandatory: true    # Liability has Liability Code, see LiabilityCode#liability
  end

  class LossTypeCode < Char
    value_type
  end

  class LossType
    identified_by   :loss_type_code
    one_to_one      :loss_type_code, mandatory: true    # Loss Type has Loss Type Code, see LossTypeCode#loss_type
    maybe           :involves_driving                   # Involves Driving
    maybe           :is_single_vehicle_incident         # Is Single Vehicle Incident
    has_one         :liability                          # Loss Type implies Liability, see Liability#all_loss_type
  end

  class VehicleIncident < Incident
    maybe           :occurred_while_being_driven        # Occurred While Being Driven
    has_one         :description                        # Vehicle Incident has Description, see Description#all_vehicle_incident
    has_one         :loss_type                          # Vehicle Incident resulted from Loss Type, see LossType#all_vehicle_incident
    has_one         :previous_damage_description, class: Description  # Vehicle Incident involved previous_damage-Description, see Description#all_vehicle_incident_as_previous_damage_description
    has_one         :reason                             # Vehicle Incident was caused by Reason, see Reason#all_vehicle_incident
    has_one         :towed_location, class: Location    # Vehicle Incident resulted in vehicle being towed to towed-Location, see Location#all_vehicle_incident_as_towed_location
    has_one         :weather_description, class: Description  # Vehicle Incident occurred during weather-Description, see Description#all_vehicle_incident_as_weather_description
  end

  class Driving
    identified_by   :vehicle_incident
    has_one         :person, mandatory: true            # Driving was by Person, see Person#all_driving
    one_to_one      :vehicle_incident, mandatory: true  # Driving involves Vehicle Incident, see VehicleIncident#driving
    has_one         :breath_test_result, class: TestResult  # Driving resulted in breath-Test Result, see TestResult#all_driving_as_breath_test_result
    has_one         :intoxication                       # Driving followed Intoxication, see Intoxication#all_driving
    has_one         :nonconsent_reason, class: Reason   # Driving was without owners consent for nonconsent-Reason, see Reason#all_driving_as_nonconsent_reason
    has_one         :unlicensed_reason, class: Reason   # Driving was unlicenced for unlicensed-Reason, see Reason#all_driving_as_unlicensed_reason
  end

  class DrivingCharge
    identified_by   :driving
    one_to_one      :driving, mandatory: true           # Driving Charge involves Driving, see Driving#driving_charge
    maybe           :is_a_warning                       # Is A Warning
    has_one         :charge, mandatory: true            # Driving Charge involves Charge, see Charge#all_driving_charge
  end

  class EngineNumber < String
    value_type
  end

  class FinanceInstitution < Company
  end

  class HospitalName < String
    value_type
  end

  class Hospital
    identified_by   :hospital_name
    one_to_one      :hospital_name, mandatory: true     # Hospital has Hospital Name, see HospitalName#hospital
  end

  class Hospitalization
    identified_by   :driving
    one_to_one      :driving, mandatory: true           # Hospitalization involves Driving, see Driving#hospitalization
    has_one         :hospital, mandatory: true          # Hospitalization involves Hospital, see Hospital#all_hospitalization
    has_one         :blood_test_result, class: TestResult  # Hospitalization resulted in blood-Test Result, see TestResult#all_hospitalization_as_blood_test_result
  end

  class Insurer < Company
  end

  class Investigator < Contractor
  end

  class LicenseNumber < String
    value_type
  end

  class LicenseType < String
    value_type
  end

  class License
    identified_by   :person
    one_to_one      :person, mandatory: true            # License is held by Person, see Person#license
    maybe           :is_international                   # Is International
    one_to_one      :license_number, mandatory: true    # License has License Number, see LicenseNumber#license
    has_one         :license_type, mandatory: true      # License is of License Type, see LicenseType#all_license
    has_one         :year                               # License was granted in Year, see Year#all_license
  end

  class Lodgement
    identified_by   :claim
    one_to_one      :claim, mandatory: true             # Lodgement involves Claim, see Claim#lodgement
    has_one         :person, mandatory: true            # Lodgement involves Person, see Person#all_lodgement
    has_one         :date_time                          # Lodgement was made at Date Time, see DateTime#all_lodgement
  end

  class LostItemNr < SignedInteger
    value_type      length: 32
  end

  class Place < String
    value_type
  end

  class Price < Decimal
    value_type      length: 18
  end

  class LostItem
    identified_by   :incident, :lost_item_nr
    has_one         :incident, mandatory: true          # Lost Item was lost in Incident, see Incident#all_lost_item
    has_one         :lost_item_nr, mandatory: true      # Lost Item has Lost Item Nr, see LostItemNr#all_lost_item
    has_one         :description, mandatory: true       # Lost Item has Description, see Description#all_lost_item
    has_one         :purchase_date, class: Date         # Lost Item was purchased on purchase-Date, see Date#all_lost_item_as_purchase_date
    has_one         :purchase_place, class: Place       # Lost Item was purchased at purchase-Place, see Place#all_lost_item_as_purchase_place
    has_one         :purchase_price, class: Price       # Lost Item was purchased for purchase-Price, see Price#all_lost_item_as_purchase_price
  end

  class Make < String
    value_type
  end

  class Model < String
    value_type
  end

  class MotorPolicy < Policy
  end

  class MotorFleetPolicy < MotorPolicy
  end

  class PartyID < AutoCounter
    value_type
  end

  class ReportNr < SignedInteger
    value_type      length: 32
  end

  class PoliceReport
    identified_by   :incident
    one_to_one      :incident, mandatory: true          # Police Report covers Incident, see Incident#police_report
    has_one         :officer_name, class: Name          # Police Report was to officer-Name, see Name#all_police_report_as_officer_name
    has_one         :police_report_nr, class: ReportNr  # Police Report has police-Report Nr, see ReportNr#all_police_report_as_police_report_nr
    has_one         :report_date_time, class: DateTime  # Police Report was on report-Date Time, see DateTime#all_police_report_as_report_date_time
    has_one         :reporter_name, class: Name         # Police Report was by reporter-Name, see Name#all_police_report_as_reporter_name
    has_one         :station_name, class: Name          # Police Report was at station-Name, see Name#all_police_report_as_station_name
  end

  class PropertyDamage
    identified_by   :incident, :address
    has_one         :incident                           # Property Damage was damaged in Incident, see Incident#all_property_damage
    has_one         :address, mandatory: true           # Property Damage is at Address, see Address#all_property_damage
    has_one         :owner_name, class: Name            # Property Damage belongs to owner-Name, see Name#all_property_damage_as_owner_name
    has_one         :phone                              # Property Damage owner has contact Phone, see Phone#all_property_damage
  end

  class RegistrationNr < Char
    value_type      length: 8
  end

  class Registration
    identified_by   :registration_nr
    one_to_one      :registration_nr, mandatory: true   # Registration has Registration Nr, see RegistrationNr#registration
  end

  class Repairer < Contractor
  end

  class SingleMotorPolicy < MotorPolicy
  end

  class Solicitor < Contractor
  end

  class Text < String
    value_type
  end

  class VehicleType
    identified_by   :make, :model, :badge
    has_one         :make, mandatory: true              # Vehicle Type is of Make, see Make#all_vehicle_type
    has_one         :model, mandatory: true             # Vehicle Type is of Model, see Model#all_vehicle_type
    has_one         :badge                              # Vehicle Type has Badge, see Badge#all_vehicle_type
  end

  class ThirdParty
    identified_by   :person, :vehicle_incident
    has_one         :person, mandatory: true            # Third Party involves Person, see Person#all_third_party
    has_one         :vehicle_incident, mandatory: true  # Third Party involves Vehicle Incident, see VehicleIncident#all_third_party
    has_one         :insurer                            # Third Party is insured by Insurer, see Insurer#all_third_party
    has_one         :model_year, class: Year            # Third Party vehicle is of model-Year, see Year#all_third_party_as_model_year
    has_one         :vehicle_registration, class: Registration  # Third Party drove vehicle-Registration, see Registration#all_third_party_as_vehicle_registration
    has_one         :vehicle_type                       # Third Party vehicle is of Vehicle Type, see VehicleType#all_third_party
  end

  class UnderwritingQuestionID < AutoCounter
    value_type
  end

  class UnderwritingQuestion
    identified_by   :underwriting_question_id
    one_to_one      :underwriting_question_id, mandatory: true, class: UnderwritingQuestionID  # Underwriting Question has Underwriting Question ID, see UnderwritingQuestionID#underwriting_question_as_underwriting_question_id
    one_to_one      :text, mandatory: true              # Underwriting Question has Text, see Text#underwriting_question
  end

  class UnderwritingDemerit
    identified_by   :vehicle_incident, :underwriting_question
    has_one         :vehicle_incident, mandatory: true  # Underwriting Demerit preceded Vehicle Incident, see VehicleIncident#all_underwriting_demerit
    has_one         :underwriting_question, mandatory: true  # Underwriting Demerit has Underwriting Question, see UnderwritingQuestion#all_underwriting_demerit
    has_one         :occurrence_count, class: Count     # Underwriting Demerit occurred occurrence-Count times, see Count#all_underwriting_demerit_as_occurrence_count
  end

  class VIN < UnsignedInteger
    value_type      length: 32
  end

  class Vehicle < Asset
    identified_by   :vin
    one_to_one      :vin, mandatory: true, class: VIN   # Vehicle has VIN, see VIN#vehicle_as_vin
    maybe           :has_commercial_registration        # Has Commercial Registration
    has_one         :model_year, mandatory: true, class: Year  # Vehicle is of model-Year, see Year#all_vehicle_as_model_year
    has_one         :registration, mandatory: true      # Vehicle has Registration, see Registration#all_vehicle
    has_one         :vehicle_type, mandatory: true      # Vehicle is of Vehicle Type, see VehicleType#all_vehicle
    has_one         :colour                             # Vehicle is of Colour, see Colour#all_vehicle
    has_one         :dealer                             # Vehicle was sold by Dealer, see Dealer#all_vehicle
    has_one         :engine_number                      # Vehicle has Engine Number, see EngineNumber#all_vehicle
    has_one         :finance_institution                # Vehicle is subject to finance with Finance Institution, see FinanceInstitution#all_vehicle
  end

  class Witness
    identified_by   :incident, :name
    has_one         :incident, mandatory: true          # Witness saw Incident, see Incident#all_witness
    has_one         :name, mandatory: true              # Witness is called Name, see Name#all_witness
    has_one         :address                            # Witness lives at Address, see Address#all_witness
    has_one         :contact_phone, class: Phone        # Witness has contact-Phone, see Phone#all_witness_as_contact_phone
  end
end
