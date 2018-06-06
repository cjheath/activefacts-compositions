#
# Auto-generated (edits will be lost) using:
# rspec spec/rails/models/models_spec.rb spec/rails/schema/schema_spec.rb
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20000000000000) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "assets", id: false, force: true do |t|
    t.column "asset_id", :primary_key, null: false
  end

  create_table "claims", id: false, force: true do |t|
    t.column "claim_id", :primary_key, null: false
    t.column "p_sequence", :integer, null: false
    t.column "policy_id", :integer, null: false
    t.column "incident_address_street", :string, limit: 256, null: true
    t.column "incident_address_city", :string, null: true
    t.column "incident_address_postcode", :string, null: true
    t.column "incident_address_state_id", :integer, null: true
    t.column "incident_date_time", :datetime, null: true
    t.column "incident_officer_name", :string, limit: 256, null: true
    t.column "incident_police_report_nr", :integer, null: true
    t.column "incident_report_date_time", :datetime, null: true
    t.column "incident_reporter_name", :string, limit: 256, null: true
    t.column "incident_station_name", :string, limit: 256, null: true
    t.column "lodgement_person_id", :integer, null: true
    t.column "lodgement_date_time", :datetime, null: true
  end

  add_index "claims", ["p_sequence", "policy_id"], name: :index_claims_on_p_sequence_policy_id, unique: true

  create_table "contractor_appointments", id: false, force: true do |t|
    t.column "claim_id", :integer, null: false
    t.column "contractor_id", :integer, null: false
  end

  add_index "contractor_appointments", ["claim_id", "contractor_id"], name: :index_contractor_appointments_on_claim_id_contractor_id, unique: true

  create_table "covers", id: false, force: true do |t|
    t.column "policy_id", :integer, null: false
    t.column "cover_type_id", :integer, null: false
    t.column "asset_id", :integer, null: false
  end

  add_index "covers", ["policy_id", "cover_type_id", "asset_id"], name: :index_covers_on_policy_id_cover_type_id_asset_id, unique: true

  create_table "cover_types", id: false, force: true do |t|
    t.column "cover_type_id", :primary_key, null: false
    t.column "cover_type_code", :string, null: false
    t.column "cover_type_name", :string, null: false
  end

  add_index "cover_types", ["cover_type_code"], name: :index_cover_types_on_cover_type_code, unique: true
  add_index "cover_types", ["cover_type_name"], name: :index_cover_types_on_cover_type_name, unique: true

  create_table "cover_wordings", id: false, force: true do |t|
    t.column "cover_wording_id", :primary_key, null: false
    t.column "cover_type_id", :integer, null: false
    t.column "policy_wording_text", :string, null: false
    t.column "start_date", :datetime, null: false
  end

  add_index "cover_wordings", ["cover_type_id", "policy_wording_text", "start_date"], name: :index_cover_wordings_on_cover_type_id_policy_wording___0ed217a9, unique: true

  create_table "loss_types", id: false, force: true do |t|
    t.column "loss_type_id", :primary_key, null: false
    t.column "loss_type_code", :string, null: false
    t.column "involves_driving", :boolean, null: true
    t.column "is_single_vehicle_incident", :boolean, null: true
    t.column "liability_code", :string, limit: 1, null: true
  end

  add_index "loss_types", ["loss_type_code"], name: :index_loss_types_on_loss_type_code, unique: true

  create_table "lost_items", id: false, force: true do |t|
    t.column "lost_item_id", :primary_key, null: false
    t.column "incident_claim_id", :integer, null: false
    t.column "lost_item_nr", :integer, null: false
    t.column "description", :string, limit: 1024, null: false
    t.column "purchase_date", :datetime, null: true
    t.column "purchase_place", :string, null: true
    t.column "purchase_price", :decimal, precision: 18, scale: 2, null: true
  end

  add_index "lost_items", ["incident_claim_id", "lost_item_nr"], name: :index_lost_items_on_incident_claim_id_lost_item_nr, unique: true

  create_table "parties", id: false, force: true do |t|
    t.column "party_id", :primary_key, null: false
    t.column "is_a_company", :boolean, null: true
    t.column "postal_address_street", :string, limit: 256, null: true
    t.column "postal_address_city", :string, null: true
    t.column "postal_address_postcode", :string, null: true
    t.column "postal_address_state_id", :integer, null: true
    t.column "company_contact_person_id", :integer, null: true
    t.column "person_business_phone_nr", :string, null: true
    t.column "person_contact_time", :time, null: true
    t.column "person_email", :string, null: true
    t.column "person_home_phone_nr", :string, null: true
    t.column "person_mobile_phone_nr", :string, null: true
    t.column "person_preferred_contact_method", :string, limit: 1, null: true
    t.column "person_family_name", :string, limit: 256, null: true
    t.column "person_given_name", :string, limit: 256, null: true
    t.column "person_title", :string, null: true
    t.column "person_address_street", :string, limit: 256, null: true
    t.column "person_address_city", :string, null: true
    t.column "person_address_postcode", :string, null: true
    t.column "person_address_state_id", :integer, null: true
    t.column "person_birth_date", :datetime, null: true
    t.column "person_is_international", :boolean, null: true
    t.column "person_license_number", :string, null: true
    t.column "person_license_type", :string, null: true
    t.column "person_year_nr", :integer, null: true
    t.column "person_occupation", :string, null: true
  end

  create_table "policies", id: false, force: true do |t|
    t.column "policy_id", :primary_key, null: false
    t.column "p_year_nr", :integer, null: false
    t.column "p_product_id", :integer, null: false
    t.column "p_state_id", :integer, null: false
    t.column "p_serial", :integer, null: false
    t.column "application_nr", :integer, null: false
    t.column "insured_id", :integer, null: false
    t.column "authorised_rep_id", :integer, null: true
    t.column "itc_claimed", :decimal, precision: 18, scale: 2, null: true
  end

  add_index "policies", ["p_year_nr", "p_product_id", "p_state_id", "p_serial"], name: :index_policies_on_p_year_nr_p_product_id_p_state_id_p_serial, unique: true

  create_table "products", id: false, force: true do |t|
    t.column "product_id", :primary_key, null: false
    t.column "product_code", :integer, null: false
    t.column "alias", :string, limit: 3, null: true
    t.column "description", :string, limit: 1024, null: true
  end

  add_index "products", ["alias"], name: :index_products_on_alias
  add_index "products", ["description"], name: :index_products_on_description
  add_index "products", ["product_code"], name: :index_products_on_product_code, unique: true

  create_table "property_damages", id: false, force: true do |t|
    t.column "property_damage_id", :primary_key, null: false
    t.column "incident_claim_id", :integer, null: true
    t.column "address_street", :string, limit: 256, null: false
    t.column "address_city", :string, null: false
    t.column "address_postcode", :string, null: true
    t.column "address_state_id", :integer, null: true
    t.column "owner_name", :string, limit: 256, null: true
    t.column "phone_nr", :string, null: true
  end

  add_index "property_damages", ["incident_claim_id", "address_street", "address_city", "address_postcode", "address_state_id"], name: :index_property_damages_on_incident_claim_id_address_s__6e1897f2

  create_table "states", id: false, force: true do |t|
    t.column "state_id", :primary_key, null: false
    t.column "state_code", :integer, null: false
    t.column "state_name", :string, limit: 256, null: true
  end

  add_index "states", ["state_code"], name: :index_states_on_state_code, unique: true
  add_index "states", ["state_name"], name: :index_states_on_state_name

  create_table "third_parties", id: false, force: true do |t|
    t.column "third_party_id", :primary_key, null: false
    t.column "person_id", :integer, null: false
    t.column "vehicle_incident_claim_id", :integer, null: false
    t.column "insurer_id", :integer, null: true
    t.column "model_year_nr", :integer, null: true
    t.column "vehicle_registration_nr", :string, limit: 8, null: true
    t.column "vehicle_type_make", :string, null: true
    t.column "vehicle_type_model", :string, null: true
    t.column "vehicle_type_badge", :string, null: true
  end

  add_index "third_parties", ["person_id", "vehicle_incident_claim_id"], name: :index_third_parties_on_person_id_vehicle_incident_claim_id, unique: true

  create_table "underwriting_demerits", id: false, force: true do |t|
    t.column "underwriting_demerit_id", :primary_key, null: false
    t.column "vehicle_incident_claim_id", :integer, null: false
    t.column "underwriting_question_id", :integer, null: false
    t.column "occurrence_count", :integer, null: true
  end

  add_index "underwriting_demerits", ["vehicle_incident_claim_id", "underwriting_question_id"], name: :index_underwriting_demerits_on_vehicle_incident_claim__47fce365, unique: true

  create_table "underwriting_questions", id: false, force: true do |t|
    t.column "underwriting_question_id", :primary_key, null: false
    t.column "text", :string, null: false
  end

  add_index "underwriting_questions", ["text"], name: :index_underwriting_questions_on_text, unique: true

  create_table "vehicles", id: false, force: true do |t|
    t.column "vehicle_id", :primary_key, null: false
    t.column "asset_id", :integer, null: false
    t.column "vin", :integer, null: false
    t.column "has_commercial_registration", :boolean, null: true
    t.column "model_year_nr", :integer, null: false
    t.column "registration_nr", :string, limit: 8, null: false
    t.column "vehicle_type_make", :string, null: false
    t.column "vehicle_type_model", :string, null: false
    t.column "vehicle_type_badge", :string, null: true
    t.column "colour", :string, null: true
    t.column "dealer_id", :integer, null: true
    t.column "engine_number", :string, null: true
    t.column "finance_institution_id", :integer, null: true
  end

  add_index "vehicles", ["vin"], name: :index_vehicles_on_vin, unique: true

  create_table "vehicle_incidents", id: false, force: true do |t|
    t.column "incident_claim_id", :integer, null: false
    t.column "occurred_while_being_driven", :boolean, null: true
    t.column "description", :string, limit: 1024, null: true
    t.column "driving_person_id", :integer, null: true
    t.column "driving_breath_test_result", :string, null: true
    t.column "driving_is_a_warning", :boolean, null: true
    t.column "driving_charge", :string, null: true
    t.column "driving_hospital_name", :string, null: true
    t.column "driving_blood_test_result", :string, null: true
    t.column "driving_intoxication", :string, null: true
    t.column "driving_nonconsent_reason", :string, null: true
    t.column "driving_unlicensed_reason", :string, null: true
    t.column "loss_type_id", :integer, null: true
    t.column "previous_damage_description", :string, limit: 1024, null: true
    t.column "reason", :string, null: true
    t.column "towed_location", :string, null: true
    t.column "weather_description", :string, limit: 1024, null: true
  end

  create_table "witnesses", id: false, force: true do |t|
    t.column "witness_id", :primary_key, null: false
    t.column "incident_claim_id", :integer, null: false
    t.column "name", :string, limit: 256, null: false
    t.column "address_street", :string, limit: 256, null: true
    t.column "address_city", :string, null: true
    t.column "address_postcode", :string, null: true
    t.column "address_state_id", :integer, null: true
    t.column "contact_phone_nr", :string, null: true
  end

  add_index "witnesses", ["incident_claim_id", "name"], name: :index_witnesses_on_incident_claim_id_name, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :claims, :parties, column: :lodgement_person_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :claims, :policies, column: :policy_id, primary_key: :policy_id, on_delete: :cascade
    add_foreign_key :claims, :states, column: :incident_address_state_id, primary_key: :state_id, on_delete: :cascade
    add_foreign_key :contractor_appointments, :claims, column: :claim_id, primary_key: :claim_id, on_delete: :cascade
    add_foreign_key :contractor_appointments, :parties, column: :contractor_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :cover_wordings, :cover_types, column: :cover_type_id, primary_key: :cover_type_id, on_delete: :cascade
    add_foreign_key :covers, :assets, column: :asset_id, primary_key: :asset_id, on_delete: :cascade
    add_foreign_key :covers, :cover_types, column: :cover_type_id, primary_key: :cover_type_id, on_delete: :cascade
    add_foreign_key :covers, :policies, column: :policy_id, primary_key: :policy_id, on_delete: :cascade
    add_foreign_key :lost_items, :claims, column: :incident_claim_id, primary_key: :claim_id, on_delete: :cascade
    add_foreign_key :parties, :parties, column: :company_contact_person_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :parties, :states, column: :person_address_state_id, primary_key: :state_id, on_delete: :cascade
    add_foreign_key :parties, :states, column: :postal_address_state_id, primary_key: :state_id, on_delete: :cascade
    add_foreign_key :policies, :parties, column: :authorised_rep_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :policies, :parties, column: :insured_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :policies, :products, column: :p_product_id, primary_key: :product_id, on_delete: :cascade
    add_foreign_key :policies, :states, column: :p_state_id, primary_key: :state_id, on_delete: :cascade
    add_foreign_key :property_damages, :claims, column: :incident_claim_id, primary_key: :claim_id, on_delete: :cascade
    add_foreign_key :property_damages, :states, column: :address_state_id, primary_key: :state_id, on_delete: :cascade
    add_foreign_key :third_parties, :parties, column: :insurer_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :third_parties, :parties, column: :person_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :third_parties, :vehicle_incidents, column: :vehicle_incident_claim_id, primary_key: :incident_claim_id, on_delete: :cascade
    add_foreign_key :underwriting_demerits, :underwriting_questions, column: :underwriting_question_id, primary_key: :underwriting_question_id, on_delete: :cascade
    add_foreign_key :underwriting_demerits, :vehicle_incidents, column: :vehicle_incident_claim_id, primary_key: :incident_claim_id, on_delete: :cascade
    add_foreign_key :vehicle_incidents, :claims, column: :incident_claim_id, primary_key: :claim_id, on_delete: :cascade
    add_foreign_key :vehicle_incidents, :loss_types, column: :loss_type_id, primary_key: :loss_type_id, on_delete: :cascade
    add_foreign_key :vehicle_incidents, :parties, column: :driving_person_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :vehicles, :assets, column: :asset_id, primary_key: :asset_id, on_delete: :cascade
    add_foreign_key :vehicles, :parties, column: :dealer_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :vehicles, :parties, column: :finance_institution_id, primary_key: :party_id, on_delete: :cascade
    add_foreign_key :witnesses, :claims, column: :incident_claim_id, primary_key: :claim_id, on_delete: :cascade
    add_foreign_key :witnesses, :states, column: :address_state_id, primary_key: :state_id, on_delete: :cascade
    add_index :claims, [:incident_address_state_id], unique: false, name: :index_claims_on_incident_address_state_id
    add_index :claims, [:lodgement_person_id], unique: false, name: :index_claims_on_lodgement_person_id
    add_index :claims, [:policy_id], unique: false, name: :index_claims_on_policy_id
    add_index :contractor_appointments, [:contractor_id], unique: false, name: :index_contractor_appointments_on_contractor_id
    add_index :covers, [:asset_id], unique: false, name: :index_covers_on_asset_id
    add_index :covers, [:cover_type_id], unique: false, name: :index_covers_on_cover_type_id
    add_index :parties, [:company_contact_person_id], unique: false, name: :index_parties_on_company_contact_person_id
    add_index :parties, [:person_address_state_id], unique: false, name: :index_parties_on_person_address_state_id
    add_index :parties, [:postal_address_state_id], unique: false, name: :index_parties_on_postal_address_state_id
    add_index :policies, [:authorised_rep_id], unique: false, name: :index_policies_on_authorised_rep_id
    add_index :policies, [:insured_id], unique: false, name: :index_policies_on_insured_id
    add_index :policies, [:p_product_id], unique: false, name: :index_policies_on_p_product_id
    add_index :policies, [:p_state_id], unique: false, name: :index_policies_on_p_state_id
    add_index :property_damages, [:address_state_id], unique: false, name: :index_property_damages_on_address_state_id
    add_index :third_parties, [:insurer_id], unique: false, name: :index_third_parties_on_insurer_id
    add_index :third_parties, [:vehicle_incident_claim_id], unique: false, name: :index_third_parties_on_vehicle_incident_claim_id
    add_index :underwriting_demerits, [:underwriting_question_id], unique: false, name: :index_underwriting_demerits_on_underwriting_question_id
    add_index :vehicle_incidents, [:driving_person_id], unique: false, name: :index_vehicle_incidents_on_driving_person_id
    add_index :vehicle_incidents, [:loss_type_id], unique: false, name: :index_vehicle_incidents_on_loss_type_id
    add_index :vehicles, [:dealer_id], unique: false, name: :index_vehicles_on_dealer_id
    add_index :vehicles, [:finance_institution_id], unique: false, name: :index_vehicles_on_finance_institution_id
    add_index :witnesses, [:address_state_id], unique: false, name: :index_witnesses_on_address_state_id
  end
end
