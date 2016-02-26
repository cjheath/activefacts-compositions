CREATE TABLE AllocatableCinemaSection (
	-- AllocatableCinemaSection involves Cinema that has Cinema ID
	CinemaID                                int NULL,
	-- AllocatableCinemaSection involves Section that has Section Name
	SectionName                             varchar NULL,
	-- Primary index to AllocatableCinemaSection over PresenceConstraint over (Cinema, Section in "Cinema provides allocated seating in Section") occurs at most one time
	PRIMARY KEY CLUSTERED(CinemaID, SectionName)
)
GO

CREATE TABLE Booking (
	-- Booking has Booking Nr
	BookingNr                               int NULL,
	-- Tickets For Booking Have Been Issued
	TicketsForBookingHaveBeenIssued         BOOLEAN,
	-- Booking involves Number
	Number                                  smallint NULL CHECK(Number >= 1),
	-- Booking involves Person that has Person ID
	PersonID                                int NULL,
	-- Booking involves Session that involves Cinema that has Cinema ID
	SessionCinemaID                         int NULL,
	-- Booking involves Session that involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       int NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Booking involves Session that involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      int NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Booking involves Session that involves Session Time that is on Day
	SessionTimeDay                          int NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Booking involves Session that involves Session Time that is at Hour
	SessionTimeHour                         int NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Booking involves Session that involves Session Time that is at Minute
	SessionTimeMinute                       int NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- maybe tickets for Booking are being mailed to Address that has Address Text
	AddressText                             text NOT NULL,
	-- maybe Booking has Collection Code
	CollectionCode                          int NOT NULL,
	-- maybe Booking is for seats in Section that has Section Name
	SectionName                             varchar NOT NULL,
	-- Primary index to Booking over PresenceConstraint over (Booking Nr in "Booking has Booking Nr") occurs at most one time
	PRIMARY KEY CLUSTERED(BookingNr),
	-- Unique index to Booking over PresenceConstraint over (Person, Session in "Person booked Session for Number of places") occurs one time
	UNIQUE NONCLUSTERED(PersonID, SessionCinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute)
)
GO

CREATE TABLE Cinema (
	-- Cinema has Cinema ID
	CinemaID                                int NULL IDENTITY,
	-- Cinema has Name
	Name                                    varchar NULL,
	-- Primary index to Cinema over PresenceConstraint over (Cinema ID in "Cinema has Cinema ID") occurs at most one time
	PRIMARY KEY CLUSTERED(CinemaID),
	-- Unique index to Cinema over PresenceConstraint over (Name in "Cinema has Name") occurs at most one time
	UNIQUE NONCLUSTERED(Name)
)
GO

CREATE TABLE Film (
	-- Film has Film ID
	FilmID                                  int NULL IDENTITY,
	-- Film has Name
	Name                                    varchar NULL,
	-- maybe Film was made in Year that has Year Nr
	YearNr                                  int NOT NULL CHECK((YearNr >= 1900 AND YearNr <= 9999)),
	-- Primary index to Film over PresenceConstraint over (Film ID in "Film has Film ID") occurs at most one time
	PRIMARY KEY CLUSTERED(FilmID)
)
GO
CREATE UNIQUE NONCLUSTERED INDEX FilmByNameYearNr ON Film(Name, YearNr) WHERE YearNr IS NOT NULL
GO

CREATE TABLE Person (
	-- Person has Person ID
	PersonID                                int NULL IDENTITY,
	-- maybe Person has Encrypted Password
	EncryptedPassword                       varchar NOT NULL,
	-- maybe Person has login-Name
	LoginName                               varchar NOT NULL,
	-- Primary index to Person over PresenceConstraint over (Person ID in "Person has Person ID") occurs at most one time
	PRIMARY KEY CLUSTERED(PersonID)
)
GO
CREATE UNIQUE NONCLUSTERED INDEX PersonByLoginName ON Person(LoginName) WHERE LoginName IS NOT NULL
GO

CREATE TABLE PlacesPaid (
	-- Places Paid involves Booking that has Booking Nr
	BookingNr                               int NULL,
	-- Places Paid involves Payment Method that has Payment Method Code
	PaymentMethodCode                       varchar NULL CHECK(PaymentMethodCode = 'Card' OR PaymentMethodCode = 'Cash' OR PaymentMethodCode = 'Gift Voucher' OR PaymentMethodCode = 'Loyalty Voucher'),
	-- Places Paid involves Number
	Number                                  smallint NULL CHECK(Number >= 1),
	-- Primary index to Places Paid over PresenceConstraint over (Booking, Payment Method in "Number of places for Booking have been paid for by Payment Method") occurs one time
	PRIMARY KEY CLUSTERED(BookingNr, PaymentMethodCode),
	FOREIGN KEY (BookingNr) REFERENCES Booking (BookingNr)
)
GO

CREATE TABLE Seat (
	-- Seat is in Row that is in Cinema that has Cinema ID
	RowCinemaID                             int NULL,
	-- Seat is in Row that has Row Nr
	RowNr                                   char(2) NULL,
	-- Seat has Seat Number
	SeatNumber                              smallint NULL,
	-- maybe Seat is in Section that has Section Name
	SectionName                             varchar NOT NULL,
	-- Primary index to Seat over PresenceConstraint over (Row, Seat Number in "Seat is in Row", "Seat has Seat Number") occurs at most one time
	PRIMARY KEY CLUSTERED(RowCinemaID, RowNr, SeatNumber),
	FOREIGN KEY (RowCinemaID) REFERENCES Cinema (CinemaID)
)
GO

CREATE TABLE SeatAllocation (
	-- Seat Allocation involves Booking that has Booking Nr
	BookingNr                               int NULL,
	-- Seat Allocation involves Seat and Seat is in Row that is in Cinema that has Cinema ID
	AllocatedSeatRowCinemaID                int NULL,
	-- Seat Allocation involves Seat and Seat is in Row that has Row Nr
	AllocatedSeatRowNr                      char(2) NULL,
	-- Seat Allocation involves Seat and Seat has Seat Number
	AllocatedSeatNumber                     smallint NULL,
	-- Primary index to Seat Allocation over PresenceConstraint over (Booking, Allocated Seat in "Booking has allocated-Seat") occurs at most one time
	PRIMARY KEY CLUSTERED(BookingNr, AllocatedSeatRowCinemaID, AllocatedSeatRowNr, AllocatedSeatNumber),
	FOREIGN KEY (AllocatedSeatRowCinemaID, AllocatedSeatRowNr, AllocatedSeatNumber) REFERENCES Seat (RowCinemaID, RowNr, SeatNumber),
	FOREIGN KEY (BookingNr) REFERENCES Booking (BookingNr)
)
GO

CREATE TABLE [Session] (
	-- Session involves Cinema that has Cinema ID
	CinemaID                                int NULL,
	-- Session involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       int NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Session involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      int NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Session involves Session Time that is on Day
	SessionTimeDay                          int NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Session involves Session Time that is at Hour
	SessionTimeHour                         int NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Session involves Session Time that is at Minute
	SessionTimeMinute                       int NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- Is High Demand
	IsHighDemand                            BOOLEAN,
	-- Uses Allocated Seating
	UsesAllocatedSeating                    BOOLEAN,
	-- Session involves Film that has Film ID
	FilmID                                  int NULL,
	-- Primary index to Session over PresenceConstraint over (Cinema, Session Time in "Cinema shows Film on Session Time") occurs one time
	PRIMARY KEY CLUSTERED(CinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute),
	FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID),
	FOREIGN KEY (FilmID) REFERENCES Film (FilmID)
)
GO

CREATE TABLE TicketPricing (
	-- Ticket Pricing involves Session Time that is in Year that has Year Nr
	SessionTimeYearNr                       int NULL CHECK((SessionTimeYearNr >= 1900 AND SessionTimeYearNr <= 9999)),
	-- Ticket Pricing involves Session Time that is in Month that has Month Nr
	SessionTimeMonthNr                      int NULL CHECK((SessionTimeMonthNr >= 1 AND SessionTimeMonthNr <= 12)),
	-- Ticket Pricing involves Session Time that is on Day
	SessionTimeDay                          int NULL CHECK((SessionTimeDay >= 1 AND SessionTimeDay <= 31)),
	-- Ticket Pricing involves Session Time that is at Hour
	SessionTimeHour                         int NULL CHECK((SessionTimeHour >= 0 AND SessionTimeHour <= 23)),
	-- Ticket Pricing involves Session Time that is at Minute
	SessionTimeMinute                       int NULL CHECK((SessionTimeMinute >= 0 AND SessionTimeMinute <= 59)),
	-- Ticket Pricing involves Cinema that has Cinema ID
	CinemaID                                int NULL,
	-- Ticket Pricing involves Section that has Section Name
	SectionName                             varchar NULL,
	-- Ticket Pricing involves High Demand
	HighDemand                              Boolean NULL,
	-- Ticket Pricing involves Price
	Price                                   decimal NULL,
	-- Primary index to Ticket Pricing over PresenceConstraint over (Session Time, Cinema, Section, High Demand in "tickets on Session Time at Cinema in Section for High Demand have Price") occurs one time
	PRIMARY KEY CLUSTERED(SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute, CinemaID, SectionName, HighDemand),
	FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID)
)
GO

ALTER TABLE Cinema
	ADD FOREIGN KEY (CinemaID) REFERENCES Cinema (CinemaID)
GO

ALTER TABLE Person
	ADD FOREIGN KEY (PersonID) REFERENCES Person (PersonID)
GO

ALTER TABLE [Session]
	ADD FOREIGN KEY (SessionCinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute) REFERENCES [Session] (CinemaID, SessionTimeYearNr, SessionTimeMonthNr, SessionTimeDay, SessionTimeHour, SessionTimeMinute)
GO
