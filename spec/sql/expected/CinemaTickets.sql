CREATE TABLE AllocatableCinemaSection (
	-- AllocatableCinemaSection involves Cinema that has Cinema ID
	CinemaID                                BIGINT NOT NULL,
	-- AllocatableCinemaSection involves Section that has Section Name
	SectionName                             VARCHAR NOT NULL,
	-- Primary index to AllocatableCinemaSection over PresenceConstraint over (Cinema, Section in "Cinema provides allocated seating in Section") occurs at most one time
	PRIMARY KEY CLUSTERED(CinemaID, SectionName)
);


CREATE TABLE Booking (
	-- Booking has Booking Nr
	BookingNr                               INTEGER NOT NULL,
	-- Tickets For Booking Have Been Issued
	TicketsForBookingHaveBeenIssued         BOOLEAN,
	-- Booking involves Number
	Number                                  SMALLINT NOT NULL CHECK(Number >= 1),
	-- Booking involves Person that has Person ID
	PersonID                                BIGINT NOT NULL,
	-- Booking involves Session that involves Cinema that has Cinema ID
	SessionCinemaID                         BIGINT NOT NULL,
	-- Booking involves Session that involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       INTEGER NOT NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Booking involves Session that involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      INTEGER NOT NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Booking involves Session that involves Session Time that is on Day
	SessionTimeDay                          INTEGER NOT NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Booking involves Session that involves Session Time that is at Hour
	SessionTimeHour                         INTEGER NOT NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Booking involves Session that involves Session Time that is at Minute
	SessionTimeMinute                       INTEGER NOT NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- maybe tickets for Booking are being mailed to Address that has Address Text
	AddressText                             VARCHAR(MAX) NULL,
	-- maybe Booking has Collection Code
	CollectionCode                          INTEGER NULL,
	-- maybe Booking is for seats in Section that has Section Name
	SectionName                             VARCHAR NULL,
	-- Primary index to Booking over PresenceConstraint over (Booking Nr in "Booking has Booking Nr") occurs at most one time
	PRIMARY KEY CLUSTERED(BookingNr),
	-- Unique index to Booking over PresenceConstraint over (Person, Session in "Person booked Session for Number of places") occurs one time
	UNIQUE NONCLUSTERED(PersonID, SessionCinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute)
);


CREATE TABLE Cinema (
	-- Cinema has Cinema ID
	CinemaID                                BIGINT NOT NULL IDENTITY,
	-- Cinema has Name
	Name                                    VARCHAR NOT NULL,
	-- Primary index to Cinema over PresenceConstraint over (Cinema ID in "Cinema has Cinema ID") occurs at most one time
	PRIMARY KEY CLUSTERED(CinemaID),
	-- Unique index to Cinema over PresenceConstraint over (Name in "Cinema has Name") occurs at most one time
	UNIQUE NONCLUSTERED(Name)
);


CREATE TABLE Film (
	-- Film has Film ID
	FilmID                                  BIGINT NOT NULL IDENTITY,
	-- Film has Name
	Name                                    VARCHAR NOT NULL,
	-- maybe Film was made in Year that has Year Nr
	YearNr                                  INTEGER NULL CHECK((YearNr >= 1900 AND YearNr <= 9999)),
	-- Primary index to Film over PresenceConstraint over (Film ID in "Film has Film ID") occurs at most one time
	PRIMARY KEY CLUSTERED(FilmID)
);

CREATE UNIQUE NONCLUSTERED INDEX FilmByNameYearNr ON Film(Name, YearNr) WHERE YearNr IS NOT NULL;


CREATE TABLE Person (
	-- Person has Person ID
	PersonID                                BIGINT NOT NULL IDENTITY,
	-- maybe Person has Encrypted Password
	EncryptedPassword                       VARCHAR NULL,
	-- maybe Person has login-Name
	LoginName                               VARCHAR NULL,
	-- Primary index to Person over PresenceConstraint over (Person ID in "Person has Person ID") occurs at most one time
	PRIMARY KEY CLUSTERED(PersonID)
);

CREATE UNIQUE NONCLUSTERED INDEX PersonByLoginName ON Person(LoginName) WHERE LoginName IS NOT NULL;


CREATE TABLE PlacesPaid (
	-- Places Paid involves Booking that has Booking Nr
	BookingNr                               INTEGER NOT NULL,
	-- Places Paid involves Payment Method that has Payment Method Code
	PaymentMethodCode                       VARCHAR NOT NULL CHECK(PaymentMethodCode = 'Card' OR PaymentMethodCode = 'Cash' OR PaymentMethodCode = 'Gift Voucher' OR PaymentMethodCode = 'Loyalty Voucher'),
	-- Places Paid involves Number
	Number                                  SMALLINT NOT NULL CHECK(Number >= 1),
	-- Primary index to Places Paid over PresenceConstraint over (Booking, Payment Method in "Number of places for Booking have been paid for by Payment Method") occurs one time
	PRIMARY KEY CLUSTERED(BookingNr, PaymentMethodCode),
	FOREIGN KEY (BookingNr) REFERENCES Booking (BookingNr)
);


CREATE TABLE Seat (
	-- Seat is in Row that is in Cinema that has Cinema ID
	RowCinemaID                             BIGINT NOT NULL,
	-- Seat is in Row that has Row Nr
	RowNr                                   CHARACTER(2) NOT NULL,
	-- Seat has Seat Number
	SeatNumber                              SMALLINT NOT NULL,
	-- maybe Seat is in Section that has Section Name
	SectionName                             VARCHAR NULL,
	-- Primary index to Seat over PresenceConstraint over (Row, Seat Number in "Seat is in Row", "Seat has Seat Number") occurs at most one time
	PRIMARY KEY CLUSTERED(RowCinemaID, RowNr, SeatNumber),
	FOREIGN KEY (RowCinemaID) REFERENCES Cinema (CinemaID)
);


CREATE TABLE SeatAllocation (
	-- Seat Allocation involves Booking that has Booking Nr
	BookingNr                               INTEGER NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat is in Row that is in Cinema that has Cinema ID
	AllocatedSeatRowCinemaID                BIGINT NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat is in Row that has Row Nr
	AllocatedSeatRowNr                      CHARACTER(2) NOT NULL,
	-- Seat Allocation involves allocated-Seat and Seat has Seat Number
	AllocatedSeatNumber                     SMALLINT NOT NULL,
	-- Primary index to Seat Allocation over PresenceConstraint over (Booking, Allocated Seat in "Booking has allocated-Seat") occurs at most one time
	PRIMARY KEY CLUSTERED(BookingNr, AllocatedSeatRowCinemaID, AllocatedSeatRowNr, AllocatedSeatNumber),
	FOREIGN KEY (AllocatedSeatRowCinemaID, AllocatedSeatRowNr, AllocatedSeatNumber) REFERENCES Seat (RowCinemaID, RowNr, SeatNumber),
	FOREIGN KEY (BookingNr) REFERENCES Booking (BookingNr)
);


CREATE TABLE [Session] (
	-- Session involves Cinema that has Cinema ID
	CinemaID                                BIGINT NOT NULL,
	-- Session involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       INTEGER NOT NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Session involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      INTEGER NOT NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Session involves Session Time that is on Day
	SessionTimeDay                          INTEGER NOT NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Session involves Session Time that is at Hour
	SessionTimeHour                         INTEGER NOT NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Session involves Session Time that is at Minute
	SessionTimeMinute                       INTEGER NOT NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- Is High Demand
	IsHighDemand                            BOOLEAN,
	-- Uses Allocated Seating
	UsesAllocatedSeating                    BOOLEAN,
	-- Session involves Film that has Film ID
	FilmID                                  BIGINT NOT NULL,
	-- Primary index to Session over PresenceConstraint over (Cinema, Session Time in "Cinema shows Film on Session Time") occurs one time
	PRIMARY KEY CLUSTERED(CinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute),
	FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID),
	FOREIGN KEY (FilmID) REFERENCES Film (FilmID)
);


CREATE TABLE TicketPricing (
	-- Ticket Pricing involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       INTEGER NOT NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Ticket Pricing involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      INTEGER NOT NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Ticket Pricing involves Session Time that is on Day
	SessionTimeDay                          INTEGER NOT NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Ticket Pricing involves Session Time that is at Hour
	SessionTimeHour                         INTEGER NOT NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Ticket Pricing involves Session Time that is at Minute
	SessionTimeMinute                       INTEGER NOT NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- Ticket Pricing involves Cinema that has Cinema ID
	CinemaID                                BIGINT NOT NULL,
	-- Ticket Pricing involves Section that has Section Name
	SectionName                             VARCHAR NOT NULL,
	-- Ticket Pricing involves High Demand
	HighDemand                               NOT NULL,
	-- Ticket Pricing involves Price
	Price                                   DECIMAL NOT NULL,
	-- Primary index to Ticket Pricing over PresenceConstraint over (Session Time, Cinema, Section, High Demand in "tickets on Session Time at Cinema in Section for High Demand have Price") occurs one time
	PRIMARY KEY CLUSTERED(SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute, CinemaID, SectionName, HighDemand),
	FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID)
);


ALTER TABLE AllocatableCinemaSection
	ADD FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID);


ALTER TABLE Booking
	ADD FOREIGN KEY (PersonID) REFERENCES Person (PersonID);


ALTER TABLE Booking
	ADD FOREIGN KEY (SessionCinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute) REFERENCES [Session] (CinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute);

