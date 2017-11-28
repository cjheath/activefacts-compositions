CREATE TABLE ALLOCATABLE_CINEMA_SECTION (
	-- AllocatableCinemaSection involves Cinema that has Cinema ID
	CINEMA_ID                               LONGINTEGER NOT NULL,
	-- AllocatableCinemaSection involves Section that has Section Name
	SECTION_NAME                            VARCHAR NOT NULL,
	-- Primary index to AllocatableCinemaSection(Cinema, Section in "Cinema provides allocated seating in Section")
	PRIMARY KEY(CINEMA_ID, SECTION_NAME)
);


CREATE TABLE BOOKING (
	-- Booking has Booking Nr
	BOOKING_NR                              INTEGER NOT NULL,
	-- Tickets For Booking Have Been Issued
	TICKETS_FOR_BOOKING_HAVE_BEEN_ISSUED    CHAR(1),
	-- Booking involves Number
	NUMBER                                  SHORTINTEGER NOT NULL CHECK(NUMBER >= 1),
	-- Booking involves Person that has Person ID
	PERSON_ID                               LONGINTEGER NOT NULL,
	-- Booking involves Session that involves Cinema that has Cinema ID
	SESSION_CINEMA_ID                       LONGINTEGER NOT NULL,
	-- Booking involves Session that involves Session Time that is in Year that has Year Nr
	SESSION_TIME_YEAR_NR                    INTEGER NOT NULL CHECK((SESSION_TIME_YEAR_NR >= 1900 AND SESSION_TIME_YEAR_NR <= 9999)),
	-- Booking involves Session that involves Session Time that is in Month that has Month Nr
	SESSION_TIME_MONTH_NR                   INTEGER NOT NULL CHECK((SESSION_TIME_MONTH_NR >= 1 AND SESSION_TIME_MONTH_NR <= 12)),
	-- Booking involves Session that involves Session Time that is on Day
	SESSION_TIME_DAY                        INTEGER NOT NULL CHECK((SESSION_TIME_DAY >= 1 AND SESSION_TIME_DAY <= 31)),
	-- Booking involves Session that involves Session Time that is at Hour
	SESSION_TIME_HOUR                       INTEGER NOT NULL CHECK((SESSION_TIME_HOUR >= 0 AND SESSION_TIME_HOUR <= 23)),
	-- Booking involves Session that involves Session Time that is at Minute
	SESSION_TIME_MINUTE                     INTEGER NOT NULL CHECK((SESSION_TIME_MINUTE >= 0 AND SESSION_TIME_MINUTE <= 59)),
	-- maybe tickets for Booking are being mailed to Address that has Address Text
	ADDRESS_TEXT                            VARCHAR(MAX) NULL,
	-- maybe Booking has Collection Code
	COLLECTION_CODE                         INTEGER NULL,
	-- maybe Booking is for seats in Section that has Section Name
	SECTION_NAME                            VARCHAR NULL,
	-- Primary index to Booking(Booking Nr in "Booking has Booking Nr")
	PRIMARY KEY(BOOKING_NR),
	-- Unique index to Booking(Person, Session in "Person booked Session for Number of places")
	UNIQUE(PERSON_ID, SESSION_CINEMA_ID, SESSION_TIME_YEAR_NR, SESSION_TIME_MONTH_NR, SESSION_TIME_DAY, SESSION_TIME_HOUR, SESSION_TIME_MINUTE)
);


CREATE TABLE CINEMA (
	-- Cinema has Cinema ID
	CINEMA_ID                               LONGINTEGER NOT NULL GENERATED BY DEFAULT ON NULL AS IDENTITY,
	-- Cinema has Name
	NAME                                    VARCHAR NOT NULL,
	-- Primary index to Cinema(Cinema ID in "Cinema has Cinema ID")
	PRIMARY KEY(CINEMA_ID),
	-- Unique index to Cinema(Name in "Cinema has Name")
	UNIQUE(NAME)
);


CREATE TABLE FILM (
	-- Film has Film ID
	FILM_ID                                 LONGINTEGER NOT NULL GENERATED BY DEFAULT ON NULL AS IDENTITY,
	-- Film has Name
	NAME                                    VARCHAR NOT NULL,
	-- maybe Film was made in Year that has Year Nr
	YEAR_NR                                 INTEGER NULL CHECK((YEAR_NR >= 1900 AND YEAR_NR <= 9999)),
	-- Primary index to Film(Film ID in "Film has Film ID")
	PRIMARY KEY(FILM_ID),
	-- Unique index to Film(Name, Year in "Film has Name", "Film was made in Year")
	UNIQUE(NAME, YEAR_NR)
);


CREATE TABLE PERSON (
	-- Person has Person ID
	PERSON_ID                               LONGINTEGER NOT NULL GENERATED BY DEFAULT ON NULL AS IDENTITY,
	-- maybe Person has Encrypted Password
	ENCRYPTED_PASSWORD                      VARCHAR NULL,
	-- maybe Person has login-Name
	LOGIN_NAME                              VARCHAR NULL,
	-- Primary index to Person(Person ID in "Person has Person ID")
	PRIMARY KEY(PERSON_ID),
	-- Unique index to Person(Login Name in "Person has login-Name")
	UNIQUE(LOGIN_NAME)
);


CREATE TABLE PLACES_PAID (
	-- Places Paid involves Booking that has Booking Nr
	BOOKING_NR                              INTEGER NOT NULL,
	-- Places Paid involves Payment Method that has Payment Method Code
	PAYMENT_METHOD_CODE                     VARCHAR NOT NULL CHECK(PAYMENT_METHOD_CODE = 'Card' OR PAYMENT_METHOD_CODE = 'Cash' OR PAYMENT_METHOD_CODE = 'Gift Voucher' OR PAYMENT_METHOD_CODE = 'Loyalty Voucher'),
	-- Places Paid involves Number
	NUMBER                                  SHORTINTEGER NOT NULL CHECK(NUMBER >= 1),
	-- Primary index to Places Paid(Booking, Payment Method in "Number of places for Booking have been paid for by Payment Method")
	PRIMARY KEY(BOOKING_NR, PAYMENT_METHOD_CODE),
	FOREIGN KEY (BOOKING_NR) REFERENCES BOOKING (BOOKING_NR)
);


CREATE TABLE SEAT (
	-- Seat is in Row that is in Cinema that has Cinema ID
	ROW_CINEMA_ID                           LONGINTEGER NOT NULL,
	-- Seat is in Row that has Row Nr
	ROW_NR                                  VARCHAR(2) NOT NULL,
	-- Seat has Seat Number
	SEAT_NUMBER                             SHORTINTEGER NOT NULL,
	-- maybe Seat is in Section that has Section Name
	SECTION_NAME                            VARCHAR NULL,
	-- Primary index to Seat(Row, Seat Number in "Seat is in Row", "Seat has Seat Number")
	PRIMARY KEY(ROW_CINEMA_ID, ROW_NR, SEAT_NUMBER),
	FOREIGN KEY (ROW_CINEMA_ID) REFERENCES CINEMA (CINEMA_ID)
);


CREATE TABLE SEAT_ALLOCATION (
	-- Seat Allocation involves Booking that has Booking Nr
	BOOKING_NR                              INTEGER NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat is in Row that is in Cinema that has Cinema ID
	ALLOCATED_SEAT_ROW_CINEMA_ID            LONGINTEGER NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat is in Row that has Row Nr
	ALLOCATED_SEAT_ROW_NR                   VARCHAR(2) NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat has Seat Number
	ALLOCATED_SEAT_NUMBER                   SHORTINTEGER NOT NULL,
	-- Primary index to Seat Allocation(Booking, Allocated Seat in "Booking has allocated-Seat")
	PRIMARY KEY(BOOKING_NR, ALLOCATED_SEAT_ROW_CINEMA_ID, ALLOCATED_SEAT_ROW_NR, ALLOCATED_SEAT_NUMBER),
	FOREIGN KEY (ALLOCATED_SEAT_ROW_CINEMA_ID, ALLOCATED_SEAT_ROW_NR, ALLOCATED_SEAT_NUMBER) REFERENCES SEAT (ROW_CINEMA_ID, ROW_NR, SEAT_NUMBER),
	FOREIGN KEY (BOOKING_NR) REFERENCES BOOKING (BOOKING_NR)
);


CREATE TABLE "SESSION" (
	-- Session involves Cinema that has Cinema ID
	CINEMA_ID                               LONGINTEGER NOT NULL,
	-- Session involves Session Time that is in Year that has Year Nr
	SESSION_TIME_YEAR_NR                    INTEGER NOT NULL CHECK((SESSION_TIME_YEAR_NR >= 1900 AND SESSION_TIME_YEAR_NR <= 9999)),
	-- Session involves Session Time that is in Month that has Month Nr
	SESSION_TIME_MONTH_NR                   INTEGER NOT NULL CHECK((SESSION_TIME_MONTH_NR >= 1 AND SESSION_TIME_MONTH_NR <= 12)),
	-- Session involves Session Time that is on Day
	SESSION_TIME_DAY                        INTEGER NOT NULL CHECK((SESSION_TIME_DAY >= 1 AND SESSION_TIME_DAY <= 31)),
	-- Session involves Session Time that is at Hour
	SESSION_TIME_HOUR                       INTEGER NOT NULL CHECK((SESSION_TIME_HOUR >= 0 AND SESSION_TIME_HOUR <= 23)),
	-- Session involves Session Time that is at Minute
	SESSION_TIME_MINUTE                     INTEGER NOT NULL CHECK((SESSION_TIME_MINUTE >= 0 AND SESSION_TIME_MINUTE <= 59)),
	-- Session Is High Demand
	IS_HIGH_DEMAND                          CHAR(1),
	-- Session Uses Allocated Seating
	USES_ALLOCATED_SEATING                  CHAR(1),
	-- Session involves Film that has Film ID
	FILM_ID                                 LONGINTEGER NOT NULL,
	-- Primary index to Session(Cinema, Session Time in "Cinema shows Film on Session Time")
	PRIMARY KEY(CINEMA_ID, SESSION_TIME_YEAR_NR, SESSION_TIME_MONTH_NR, SESSION_TIME_DAY, SESSION_TIME_HOUR, SESSION_TIME_MINUTE),
	FOREIGN KEY (CINEMA_ID) REFERENCES CINEMA (CINEMA_ID),
	FOREIGN KEY (FILM_ID) REFERENCES FILM (FILM_ID)
);


CREATE TABLE TICKET_PRICING (
	-- Ticket Pricing involves Session Time that is in Year that has Year Nr
	SESSION_TIME_YEAR_NR                    INTEGER NOT NULL CHECK((SESSION_TIME_YEAR_NR >= 1900 AND SESSION_TIME_YEAR_NR <= 9999)),
	-- Ticket Pricing involves Session Time that is in Month that has Month Nr
	SESSION_TIME_MONTH_NR                   INTEGER NOT NULL CHECK((SESSION_TIME_MONTH_NR >= 1 AND SESSION_TIME_MONTH_NR <= 12)),
	-- Ticket Pricing involves Session Time that is on Day
	SESSION_TIME_DAY                        INTEGER NOT NULL CHECK((SESSION_TIME_DAY >= 1 AND SESSION_TIME_DAY <= 31)),
	-- Ticket Pricing involves Session Time that is at Hour
	SESSION_TIME_HOUR                       INTEGER NOT NULL CHECK((SESSION_TIME_HOUR >= 0 AND SESSION_TIME_HOUR <= 23)),
	-- Ticket Pricing involves Session Time that is at Minute
	SESSION_TIME_MINUTE                     INTEGER NOT NULL CHECK((SESSION_TIME_MINUTE >= 0 AND SESSION_TIME_MINUTE <= 59)),
	-- Ticket Pricing involves Cinema that has Cinema ID
	CINEMA_ID                               LONGINTEGER NOT NULL,
	-- Ticket Pricing involves Section that has Section Name
	SECTION_NAME                            VARCHAR NOT NULL,
	-- Ticket Pricing involves High Demand
	HIGH_DEMAND                             CHAR(1) NOT NULL,
	-- Ticket Pricing involves Price
	PRICE                                   MONEY NOT NULL,
	-- Primary index to Ticket Pricing(Session Time, Cinema, Section, High Demand in "tickets on Session Time at Cinema in Section for High Demand have Price")
	PRIMARY KEY(SESSION_TIME_YEAR_NR, SESSION_TIME_MONTH_NR, SESSION_TIME_DAY, SESSION_TIME_HOUR, SESSION_TIME_MINUTE, CINEMA_ID, SECTION_NAME, HIGH_DEMAND),
	FOREIGN KEY (CINEMA_ID) REFERENCES CINEMA (CINEMA_ID)
);


ALTER TABLE ALLOCATABLE_CINEMA_SECTION
	ADD FOREIGN KEY (CINEMA_ID) REFERENCES CINEMA (CINEMA_ID);

ALTER TABLE BOOKING
	ADD FOREIGN KEY (PERSON_ID) REFERENCES PERSON (PERSON_ID);

ALTER TABLE BOOKING
	ADD FOREIGN KEY (SESSION_CINEMA_ID, SESSION_TIME_YEAR_NR, SESSION_TIME_MONTH_NR, SESSION_TIME_DAY, SESSION_TIME_HOUR, SESSION_TIME_MINUTE) REFERENCES "SESSION" (CINEMA_ID, SESSION_TIME_YEAR_NR, SESSION_TIME_MONTH_NR, SESSION_TIME_DAY, SESSION_TIME_HOUR, SESSION_TIME_MINUTE);
