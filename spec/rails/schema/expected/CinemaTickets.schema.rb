#
# schema.rb auto-generated for CinemaTickets
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20000000000000) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "allocatable_cinema_sections", id: false, force: true do |t|
    t.column "allocatable_cinema_section_id", :primary_key, null: false
    t.column "cinema_id", :integer, null: false
    t.column "section_name", :string, null: false
  end

  add_index "allocatable_cinema_sections", ["cinema_id", "section_name"], name: :index_allocatable_cinema_sections_on_cinema_id_section_name, unique: true

  create_table "bookings", id: false, force: true do |t|
    t.column "booking_id", :primary_key, null: false
    t.column "booking_nr", :integer, null: false
    t.column "tickets_for_booking_have_been_issued", :boolean, null: true
    t.column "number", :integer, null: false
    t.column "person_id", :integer, null: false
    t.column "session_id", :integer, null: false
    t.column "address_text", :text, null: true
    t.column "collection_code", :integer, null: true
    t.column "section_name", :string, null: true
  end

  add_index "bookings", ["booking_nr"], name: :index_bookings_on_booking_nr, unique: true
  add_index "bookings", ["person_id", "session_id"], name: :index_bookings_on_person_id_session_id, unique: true

  create_table "cinemas", id: false, force: true do |t|
    t.column "cinema_id", :primary_key, null: false
    t.column "name", :string, null: false
  end

  add_index "cinemas", ["name"], name: :index_cinemas_on_name, unique: true

  create_table "films", id: false, force: true do |t|
    t.column "film_id", :primary_key, null: false
    t.column "name", :string, null: false
    t.column "year_nr", :integer, null: true
  end

  add_index "films", ["name", "year_nr"], name: :index_films_on_name_year_nr

  create_table "people", id: false, force: true do |t|
    t.column "person_id", :primary_key, null: false
    t.column "encrypted_password", :string, null: true
    t.column "login_name", :string, null: true
  end

  add_index "people", ["login_name"], name: :index_people_on_login_name

  create_table "places_paids", id: false, force: true do |t|
    t.column "places_paid_id", :primary_key, null: false
    t.column "booking_id", :integer, null: false
    t.column "payment_method_code", :string, null: false
    t.column "number", :integer, null: false
  end

  add_index "places_paids", ["booking_id", "payment_method_code"], name: :index_places_paids_on_booking_id_payment_method_code, unique: true

  create_table "seats", id: false, force: true do |t|
    t.column "seat_id", :primary_key, null: false
    t.column "row_cinema_id", :integer, null: false
    t.column "row_nr", :string, limit: 2, null: false
    t.column "seat_number", :integer, null: false
    t.column "section_name", :string, null: true
  end

  add_index "seats", ["row_cinema_id", "row_nr", "seat_number"], name: :index_seats_on_row_cinema_id_row_nr_seat_number, unique: true

  create_table "seat_allocations", id: false, force: true do |t|
    t.column "booking_id", :integer, null: false
    t.column "allocated_seat_id", :integer, null: false
  end

  add_index "seat_allocations", ["booking_id", "allocated_seat_id"], name: :index_seat_allocations_on_booking_id_allocated_seat_id, unique: true

  create_table "sessions", id: false, force: true do |t|
    t.column "session_id", :primary_key, null: false
    t.column "cinema_id", :integer, null: false
    t.column "session_time_year_nr", :integer, null: false
    t.column "session_time_month_nr", :integer, null: false
    t.column "session_time_day", :integer, null: false
    t.column "session_time_hour", :integer, null: false
    t.column "session_time_minute", :integer, null: false
    t.column "is_high_demand", :boolean, null: true
    t.column "uses_allocated_seating", :boolean, null: true
    t.column "film_id", :integer, null: false
  end

  add_index "sessions", ["cinema_id", "session_time_year_nr", "session_time_month_nr", "session_time_day", "session_time_hour", "session_time_minute"], name: :index_sessions_on_cinema_id_session_time_year_nr_sess__7a05f3be, unique: true

  create_table "ticket_pricings", id: false, force: true do |t|
    t.column "ticket_pricing_id", :primary_key, null: false
    t.column "session_time_year_nr", :integer, null: false
    t.column "session_time_month_nr", :integer, null: false
    t.column "session_time_day", :integer, null: false
    t.column "session_time_hour", :integer, null: false
    t.column "session_time_minute", :integer, null: false
    t.column "cinema_id", :integer, null: false
    t.column "section_name", :string, null: false
    t.column "high_demand", :boolean, null: false
    t.column "price", :decimal, null: false
  end

  add_index "ticket_pricings", ["session_time_year_nr", "session_time_month_nr", "session_time_day", "session_time_hour", "session_time_minute", "cinema_id", "section_name", "high_demand"], name: :index_ticket_pricings_on_session_time_year_nr_session__181a38a0, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :allocatable_cinema_sections, :cinemas, column: :cinema_id, primary_key: :cinema_id, on_delete: :cascade
    add_foreign_key :bookings, :people, column: :person_id, primary_key: :person_id, on_delete: :cascade
    add_foreign_key :bookings, :sessions, column: :session_id, primary_key: :session_id, on_delete: :cascade
    add_foreign_key :places_paids, :bookings, column: :booking_id, primary_key: :booking_id, on_delete: :cascade
    add_foreign_key :seat_allocations, :bookings, column: :booking_id, primary_key: :booking_id, on_delete: :cascade
    add_foreign_key :seat_allocations, :seats, column: :allocated_seat_id, primary_key: :seat_id, on_delete: :cascade
    add_foreign_key :seats, :cinemas, column: :row_cinema_id, primary_key: :cinema_id, on_delete: :cascade
    add_foreign_key :sessions, :cinemas, column: :cinema_id, primary_key: :cinema_id, on_delete: :cascade
    add_foreign_key :sessions, :films, column: :film_id, primary_key: :film_id, on_delete: :cascade
    add_foreign_key :ticket_pricings, :cinemas, column: :cinema_id, primary_key: :cinema_id, on_delete: :cascade
    add_index :bookings, [:session_id], unique: false, name: :index_bookings_on_session_id
    add_index :seat_allocations, [:allocated_seat_id], unique: false, name: :index_seat_allocations_on_allocated_seat_id
    add_index :sessions, [:film_id], unique: false, name: :index_sessions_on_film_id
    add_index :ticket_pricings, [:cinema_id], unique: false, name: :index_ticket_pricings_on_cinema_id
  end
end
