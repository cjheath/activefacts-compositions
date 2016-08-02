#
# schema.rb auto-generated for CompanyDirectorEmployee
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160802114147) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "attendances", id: false, force: true do |t|
    t.column "attendee_person_id", :integer, null: false
    t.column "meeting_id", :integer, null: false
  end

  add_index "attendances", ["attendee_person_id", "meeting_id"], name: :index_attendances_on_attendee_person_id_meeting_id, unique: true

  create_table "companies", id: false, force: true do |t|
    t.column "company_id", :primary_key, null: false
    t.column "company_name", :string, limit: 48, null: false
    t.column "is_listed", :boolean, null: true
  end

  add_index "companies", ["company_name"], name: :index_companies_on_company_name, unique: true

  create_table "directorships", id: false, force: true do |t|
    t.column "directorship_id", :primary_key, null: false
    t.column "director_person_id", :integer, null: false
    t.column "company_id", :integer, null: false
    t.column "appointment_date", :datetime, null: false
  end

  add_index "directorships", ["director_person_id", "company_id"], name: :index_directorships_on_director_person_id_company_id, unique: true

  create_table "employees", id: false, force: true do |t|
    t.column "employee_id", :primary_key, null: false
    t.column "employee_nr", :integer, null: false
    t.column "company_id", :integer, null: false
    t.column "manager_employee_id", :integer, null: false
    t.column "manager_is_ceo", :boolean, null: true
  end

  add_index "employees", ["employee_nr"], name: :index_employees_on_employee_nr, unique: true

  create_table "employments", id: false, force: true do |t|
    t.column "person_id", :integer, null: false
    t.column "employee_id", :integer, null: false
  end

  add_index "employments", ["person_id", "employee_id"], name: :index_employments_on_person_id_employee_id, unique: true

  create_table "meetings", id: false, force: true do |t|
    t.column "meeting_id", :primary_key, null: false
    t.column "company_id", :integer, null: false
    t.column "date", :datetime, null: false
    t.column "is_board_meeting", :boolean, null: true
  end

  add_index "meetings", ["company_id", "date", "is_board_meeting"], name: :index_meetings_on_company_id_date_is_board_meeting, unique: true

  create_table "people", id: false, force: true do |t|
    t.column "person_id", :primary_key, null: false
    t.column "given_name", :string, limit: 48, null: false
    t.column "family_name", :string, limit: 48, null: true
    t.column "birth_date", :datetime, null: true
  end

  add_index "people", ["given_name", "family_name"], name: :index_people_on_given_name_family_name

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :attendances, :meetings, column: :meeting_id, primary_key: :meeting_id, on_delete: :cascade
    add_foreign_key :attendances, :people, column: :attendee_person_id, primary_key: :person_id, on_delete: :cascade
    add_foreign_key :directorships, :companies, column: :company_id, primary_key: :company_id, on_delete: :cascade
    add_foreign_key :directorships, :people, column: :director_person_id, primary_key: :person_id, on_delete: :cascade
    add_foreign_key :employees, :companies, column: :company_id, primary_key: :company_id, on_delete: :cascade
    add_foreign_key :employees, :employees, column: :manager_employee_id, primary_key: :employee_id, on_delete: :cascade
    add_foreign_key :employments, :employees, column: :employee_id, primary_key: :employee_id, on_delete: :cascade
    add_foreign_key :employments, :people, column: :person_id, primary_key: :person_id, on_delete: :cascade
    add_foreign_key :meetings, :companies, column: :company_id, primary_key: :company_id, on_delete: :cascade
    add_index :attendances, [:attendee_person_id], unique: false, name: :index_attendances_on_attendee_person_id
    add_index :attendances, [:meeting_id], unique: false, name: :index_attendances_on_meeting_id
    add_index :directorships, [:company_id], unique: false, name: :index_directorships_on_company_id
    add_index :directorships, [:director_person_id], unique: false, name: :index_directorships_on_director_person_id
    add_index :employees, [:company_id], unique: false, name: :index_employees_on_company_id
    add_index :employees, [:manager_employee_id], unique: false, name: :index_employees_on_manager_employee_id
    add_index :employments, [:employee_id], unique: false, name: :index_employments_on_employee_id
    add_index :employments, [:person_id], unique: false, name: :index_employments_on_person_id
    add_index :meetings, [:company_id], unique: false, name: :index_meetings_on_company_id
  end
end
