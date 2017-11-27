CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE allocatable_cinema_section (
	-- AllocatableCinemaSection surrogate key
	allocatable_cinema_section_id           BIGSERIAL NOT NULL,
	-- AllocatableCinemaSection involves Cinema that has Cinema ID
	cinema_id                               BIGINT NOT NULL,
	-- AllocatableCinemaSection involves Section that has Section Name
	section_name                            VARCHAR NOT NULL,
	-- Natural index to AllocatableCinemaSection(Cinema, Section in "Cinema provides allocated seating in Section")
	UNIQUE(cinema_id, section_name),
	-- Primary index to AllocatableCinemaSection
	PRIMARY KEY(allocatable_cinema_section_id)
);


CREATE TABLE booking (
	-- Booking surrogate key
	booking_id                              BIGSERIAL NOT NULL,
	-- Booking has Booking Nr
	booking_nr                              INTEGER NOT NULL,
	-- Tickets For Booking Have Been Issued
	tickets_for_booking_have_been_issued    BOOLEAN,
	-- Booking involves Number
	number                                  SMALLINT NOT NULL CHECK(number >= 1),
	-- Booking involves Person that has Person ID
	person_id                               BIGINT NOT NULL,
	-- Booking involves Session
	session_id                              BIGINT NOT NULL,
	-- maybe tickets for Booking are being mailed to Address that has Address Text
	address_text                            VARCHAR(MAX) NULL,
	-- maybe Booking has Collection Code
	collection_code                         INTEGER NULL,
	-- maybe Booking is for seats in Section that has Section Name
	section_name                            VARCHAR NULL,
	-- Natural index to Booking(Booking Nr in "Booking has Booking Nr")
	UNIQUE(booking_nr),
	-- Primary index to Booking
	PRIMARY KEY(booking_id),
	-- Unique index to Booking(Person, Session in "Person booked Session for Number of places")
	UNIQUE(person_id, session_id)
);


CREATE TABLE cinema (
	-- Cinema has Cinema ID
	cinema_id                               BIGSERIAL NOT NULL,
	-- Cinema has Name
	name                                    VARCHAR NOT NULL,
	-- Primary index to Cinema(Cinema ID in "Cinema has Cinema ID")
	PRIMARY KEY(cinema_id),
	-- Unique index to Cinema(Name in "Cinema has Name")
	UNIQUE(name)
);


CREATE TABLE film (
	-- Film has Film ID
	film_id                                 BIGSERIAL NOT NULL,
	-- Film has Name
	name                                    VARCHAR NOT NULL,
	-- maybe Film was made in Year that has Year Nr
	year_nr                                 INTEGER NULL CHECK((year_nr >= 1900 AND year_nr <= 9999)),
	-- Primary index to Film(Film ID in "Film has Film ID")
	PRIMARY KEY(film_id),
	-- Unique index to Film(Name, Year in "Film has Name", "Film was made in Year")
	UNIQUE(name, year_nr)
);


CREATE TABLE person (
	-- Person has Person ID
	person_id                               BIGSERIAL NOT NULL,
	-- maybe Person has Encrypted Password
	encrypted_password                      VARCHAR NULL,
	-- maybe Person has login-Name
	login_name                              VARCHAR NULL,
	-- Primary index to Person(Person ID in "Person has Person ID")
	PRIMARY KEY(person_id),
	-- Unique index to Person(Login Name in "Person has login-Name")
	UNIQUE(login_name)
);


CREATE TABLE places_paid (
	-- Places Paid surrogate key
	places_paid_id                          BIGSERIAL NOT NULL,
	-- Places Paid involves Booking
	booking_id                              BIGINT NOT NULL,
	-- Places Paid involves Payment Method that has Payment Method Code
	payment_method_code                     VARCHAR NOT NULL CHECK(payment_method_code = 'Card' OR payment_method_code = 'Cash' OR payment_method_code = 'Gift Voucher' OR payment_method_code = 'Loyalty Voucher'),
	-- Places Paid involves Number
	number                                  SMALLINT NOT NULL CHECK(number >= 1),
	-- Natural index to Places Paid(Booking, Payment Method in "Number of places for Booking have been paid for by Payment Method")
	UNIQUE(booking_id, payment_method_code),
	-- Primary index to Places Paid
	PRIMARY KEY(places_paid_id),
	FOREIGN KEY (booking_id) REFERENCES booking (booking_id)
);


CREATE TABLE seat (
	-- Seat surrogate key
	seat_id                                 BIGSERIAL NOT NULL,
	-- Seat is in Row that is in Cinema that has Cinema ID
	row_cinema_id                           BIGINT NOT NULL,
	-- Seat is in Row that has Row Nr
	row_nr                                  VARCHAR(2) NOT NULL,
	-- Seat has Seat Number
	seat_number                             SMALLINT NOT NULL,
	-- maybe Seat is in Section that has Section Name
	section_name                            VARCHAR NULL,
	-- Natural index to Seat(Row, Seat Number in "Seat is in Row", "Seat has Seat Number")
	UNIQUE(row_cinema_id, row_nr, seat_number),
	-- Primary index to Seat
	PRIMARY KEY(seat_id),
	FOREIGN KEY (row_cinema_id) REFERENCES cinema (cinema_id)
);


CREATE TABLE seat_allocation (
	-- Seat Allocation involves Booking
	booking_id                              BIGINT NOT NULL,
	-- Seat Allocation involves allocated-Seat
	allocated_seat_id                       BIGINT NOT NULL,
	-- Primary index to Seat Allocation(Booking, Allocated Seat in "Booking has allocated-Seat")
	PRIMARY KEY(booking_id, allocated_seat_id),
	FOREIGN KEY (allocated_seat_id) REFERENCES seat (seat_id),
	FOREIGN KEY (booking_id) REFERENCES booking (booking_id)
);


CREATE TABLE "session" (
	-- Session surrogate key
	session_id                              BIGSERIAL NOT NULL,
	-- Session involves Cinema that has Cinema ID
	cinema_id                               BIGINT NOT NULL,
	-- Session involves Session Time that is in Year that has Year Nr
	session_time_year_nr                    INTEGER NOT NULL CHECK((session_time_year_nr >= 1900 AND session_time_year_nr <= 9999)),
	-- Session involves Session Time that is in Month that has Month Nr
	session_time_month_nr                   INTEGER NOT NULL CHECK((session_time_month_nr >= 1 AND session_time_month_nr <= 12)),
	-- Session involves Session Time that is on Day
	session_time_day                        INTEGER NOT NULL CHECK((session_time_day >= 1 AND session_time_day <= 31)),
	-- Session involves Session Time that is at Hour
	session_time_hour                       INTEGER NOT NULL CHECK((session_time_hour >= 0 AND session_time_hour <= 23)),
	-- Session involves Session Time that is at Minute
	session_time_minute                     INTEGER NOT NULL CHECK((session_time_minute >= 0 AND session_time_minute <= 59)),
	-- Session Is High Demand
	is_high_demand                          BOOLEAN,
	-- Session Uses Allocated Seating
	uses_allocated_seating                  BOOLEAN,
	-- Session involves Film that has Film ID
	film_id                                 BIGINT NOT NULL,
	-- Natural index to Session(Cinema, Session Time in "Cinema shows Film on Session Time")
	UNIQUE(cinema_id, session_time_year_nr, session_time_month_nr, session_time_day, session_time_hour, session_time_minute),
	-- Primary index to Session
	PRIMARY KEY(session_id),
	FOREIGN KEY (cinema_id) REFERENCES cinema (cinema_id),
	FOREIGN KEY (film_id) REFERENCES film (film_id)
);


CREATE TABLE ticket_pricing (
	-- Ticket Pricing surrogate key
	ticket_pricing_id                       BIGSERIAL NOT NULL,
	-- Ticket Pricing involves Session Time that is in Year that has Year Nr
	session_time_year_nr                    INTEGER NOT NULL CHECK((session_time_year_nr >= 1900 AND session_time_year_nr <= 9999)),
	-- Ticket Pricing involves Session Time that is in Month that has Month Nr
	session_time_month_nr                   INTEGER NOT NULL CHECK((session_time_month_nr >= 1 AND session_time_month_nr <= 12)),
	-- Ticket Pricing involves Session Time that is on Day
	session_time_day                        INTEGER NOT NULL CHECK((session_time_day >= 1 AND session_time_day <= 31)),
	-- Ticket Pricing involves Session Time that is at Hour
	session_time_hour                       INTEGER NOT NULL CHECK((session_time_hour >= 0 AND session_time_hour <= 23)),
	-- Ticket Pricing involves Session Time that is at Minute
	session_time_minute                     INTEGER NOT NULL CHECK((session_time_minute >= 0 AND session_time_minute <= 59)),
	-- Ticket Pricing involves Cinema that has Cinema ID
	cinema_id                               BIGINT NOT NULL,
	-- Ticket Pricing involves Section that has Section Name
	section_name                            VARCHAR NOT NULL,
	-- Ticket Pricing involves High Demand
	high_demand                             BOOLEAN NOT NULL,
	-- Ticket Pricing involves Price
	price                                   MONEY NOT NULL,
	-- Natural index to Ticket Pricing(Session Time, Cinema, Section, High Demand in "tickets on Session Time at Cinema in Section for High Demand have Price")
	UNIQUE(session_time_year_nr, session_time_month_nr, session_time_day, session_time_hour, session_time_minute, cinema_id, section_name, high_demand),
	-- Primary index to Ticket Pricing
	PRIMARY KEY(ticket_pricing_id),
	FOREIGN KEY (cinema_id) REFERENCES cinema (cinema_id)
);


ALTER TABLE allocatable_cinema_section
	ADD FOREIGN KEY (cinema_id) REFERENCES cinema (cinema_id);


ALTER TABLE booking
	ADD FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE booking
	ADD FOREIGN KEY (session_id) REFERENCES "session" (session_id);

