require 'activefacts/api'

module CinemaTickets
  class AddressText < Text
    value_type
  end

  class Address
    identified_by   :address_text
    one_to_one      :address_text, mandatory: true      # Address has Address Text, see AddressText#address
  end

  class CinemaID < AutoCounter
    value_type
  end

  class Name < String
    value_type
  end

  class Cinema
    identified_by   :cinema_id
    one_to_one      :cinema_id, mandatory: true, class: CinemaID  # Cinema has Cinema ID, see CinemaID#cinema_as_cinema_id
    one_to_one      :name, mandatory: true              # Cinema has Name, see Name#cinema
  end

  class SectionName < String
    value_type
  end

  class Section
    identified_by   :section_name
    one_to_one      :section_name, mandatory: true      # Section has Section Name, see SectionName#section
  end

  class AllocatableCinemaSection
    identified_by   :cinema, :section
    has_one         :cinema, mandatory: true            # AllocatableCinemaSection involves Cinema, see Cinema#all_allocatable_cinema_section
    has_one         :section, mandatory: true           # AllocatableCinemaSection involves Section, see Section#all_allocatable_cinema_section
  end

  class BookingNr < SignedInteger
    value_type      length: 32
  end

  class CollectionCode < SignedInteger
    value_type      length: 32
  end

  class Number < UnsignedInteger
    value_type      length: 16
  end

  class EncryptedPassword < String
    value_type
  end

  class PersonID < AutoCounter
    value_type
  end

  class Person
    identified_by   :person_id
    one_to_one      :person_id, mandatory: true, class: PersonID  # Person has Person ID, see PersonID#person_as_person_id
    has_one         :encrypted_password                 # Person has Encrypted Password, see EncryptedPassword#all_person
    one_to_one      :login_name, class: Name            # Person has login-Name, see Name#person_as_login_name
  end

  class FilmID < AutoCounter
    value_type
  end

  class YearNr < SignedInteger
    value_type      length: 32
  end

  class Year
    identified_by   :year_nr
    one_to_one      :year_nr, mandatory: true           # Year has Year Nr, see YearNr#year
  end

  class Film
    identified_by   :film_id
    one_to_one      :film_id, mandatory: true, class: FilmID  # Film has Film ID, see FilmID#film_as_film_id
    has_one         :name, mandatory: true              # Film has Name, see Name#all_film
    has_one         :year                               # Film was made in Year, see Year#all_film
  end

  class Day < SignedInteger
    value_type      length: 32
  end

  class Hour < SignedInteger
    value_type      length: 32
  end

  class Minute < SignedInteger
    value_type      length: 32
  end

  class MonthNr < SignedInteger
    value_type      length: 32
  end

  class Month
    identified_by   :month_nr
    one_to_one      :month_nr, mandatory: true          # Month has Month Nr, see MonthNr#month
  end

  class SessionTime
    identified_by   :year, :month, :day, :hour, :minute
    has_one         :year, mandatory: true              # Session Time is in Year, see Year#all_session_time
    has_one         :month, mandatory: true             # Session Time is in Month, see Month#all_session_time
    has_one         :day, mandatory: true               # Session Time is on Day, see Day#all_session_time
    has_one         :hour, mandatory: true              # Session Time is at Hour, see Hour#all_session_time
    has_one         :minute, mandatory: true            # Session Time is at Minute, see Minute#all_session_time
  end

  class Session
    identified_by   :cinema, :session_time
    has_one         :cinema, mandatory: true            # Session involves Cinema, see Cinema#all_session
    has_one         :session_time, mandatory: true      # Session involves Session Time, see SessionTime#all_session
    maybe           :is_high_demand                     # Is High Demand
    maybe           :uses_allocated_seating             # Uses Allocated Seating
    has_one         :film, mandatory: true              # Session involves Film, see Film#all_session
  end

  class Booking
    identified_by   :booking_nr
    one_to_one      :booking_nr, mandatory: true        # Booking has Booking Nr, see BookingNr#booking
    maybe           :tickets_for_booking_have_been_issued  # Tickets For Booking Have Been Issued
    has_one         :number, mandatory: true            # Booking involves Number, see Number#all_booking
    has_one         :person, mandatory: true            # Booking involves Person, see Person#all_booking
    has_one         :session, mandatory: true           # Booking involves Session, see Session#all_booking
    has_one         :address                            # tickets for Booking are being mailed to Address, see Address#all_booking
    has_one         :collection_code                    # Booking has Collection Code, see CollectionCode#all_booking
    has_one         :section                            # Booking is for seats in Section, see Section#all_booking
  end

  class HighDemand < Boolean
    value_type
  end

  class PaymentMethodCode < String
    value_type
  end

  class PaymentMethod
    identified_by   :payment_method_code
    one_to_one      :payment_method_code, mandatory: true  # Payment Method has Payment Method Code, see PaymentMethodCode#payment_method
  end

  class PlacesPaid
    identified_by   :booking, :payment_method
    has_one         :booking, mandatory: true           # Places Paid involves Booking, see Booking#all_places_paid
    has_one         :payment_method, mandatory: true    # Places Paid involves Payment Method, see PaymentMethod#all_places_paid
    has_one         :number, mandatory: true            # Places Paid involves Number, see Number#all_places_paid
  end

  class Price < Money
    value_type
  end

  class RowNr < Char
    value_type      length: 2
  end

  class Row
    identified_by   :cinema, :row_nr
    has_one         :cinema, mandatory: true            # Row is in Cinema, see Cinema#all_row
    has_one         :row_nr, mandatory: true            # Row has Row Nr, see RowNr#all_row
  end

  class SeatNumber < UnsignedInteger
    value_type      length: 16
  end

  class Seat
    identified_by   :row, :seat_number
    has_one         :row, mandatory: true               # Seat is in Row, see Row#all_seat
    has_one         :seat_number, mandatory: true       # Seat has Seat Number, see SeatNumber#all_seat
    has_one         :section                            # Seat is in Section, see Section#all_seat
  end

  class SeatAllocation
    identified_by   :booking, :allocated_seat
    has_one         :booking, mandatory: true           # Seat Allocation involves Booking, see Booking#all_seat_allocation
    has_one         :allocated_seat, mandatory: true, class: Seat  # Seat Allocation involves allocated-Seat, see Seat#all_seat_allocation_as_allocated_seat
  end

  class TicketPricing
    identified_by   :session_time, :cinema, :section, :high_demand
    has_one         :session_time, mandatory: true      # Ticket Pricing involves Session Time, see SessionTime#all_ticket_pricing
    has_one         :cinema, mandatory: true            # Ticket Pricing involves Cinema, see Cinema#all_ticket_pricing
    has_one         :section, mandatory: true           # Ticket Pricing involves Section, see Section#all_ticket_pricing
    has_one         :high_demand, mandatory: true       # Ticket Pricing involves High Demand, see HighDemand#all_ticket_pricing
    has_one         :price, mandatory: true             # Ticket Pricing involves Price, see Price#all_ticket_pricing
  end
end
