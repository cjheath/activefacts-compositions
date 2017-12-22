CREATE TABLE AirlineHUB (
	-- Airline HUB surrogate key
	AirlineHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airline has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Airline HUB(Airline ID in "Airline has Airline ID")
	UNIQUE(AirlineID),
	-- Primary index to Airline HUB
	PRIMARY KEY(AirlineHID)
);


CREATE TABLE AirlineSAT (
	-- Airline
	AirlineHID                              BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- maybe Airline has Flight Code
	FlightCode                              BIGINT NULL,
	-- Primary index to Airline SAT
	PRIMARY KEY(AirlineHID, LoadTime),
	FOREIGN KEY (AirlineHID) REFERENCES AirlineHUB (AirlineHID)
);


CREATE TABLE AirplaneHUB (
	-- Airplane HUB surrogate key
	AirplaneHID                             BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airplane has Tail Number
	TailNumber                              VARCHAR(12) NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Airplane HUB(Tail Number in "Airplane has Tail Number")
	UNIQUE(TailNumber),
	-- Primary index to Airplane HUB
	PRIMARY KEY(AirplaneHID)
);


CREATE TABLE AirplanePartLINK (
	-- Airplane Part LINK surrogate key
	AirplanePartHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airplane Part involves Airplane
	AirplaneHID                             BIGINT NOT NULL,
	-- Airplane Part involves Part
	PartHID                                 BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Airplane Part LINK(Airplane, Part in "Airplane has Part")
	UNIQUE(AirplaneHID, PartHID),
	-- Primary index to Airplane Part LINK
	PRIMARY KEY(AirplanePartHID),
	FOREIGN KEY (AirplaneHID) REFERENCES AirplaneHUB (AirplaneHID)
);


CREATE TABLE AirportHUB (
	-- Airport HUB surrogate key
	AirportHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airport has Airport Name
	AirportName                             VARCHAR(48) NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Airport HUB(Airport Name in "Airport has Airport Name")
	UNIQUE(AirportName),
	-- Primary index to Airport HUB
	PRIMARY KEY(AirportHID)
);


CREATE TABLE AirportSAT (
	-- Airport
	AirportHID                              BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Airport has at Telephone Number
	TelephoneNumber                         VARCHAR(12) NOT NULL,
	-- maybe Airport is Latitude
	Latitude                                DECIMAL(10, 4) NULL,
	-- maybe Airport is Longitude
	Longitude                               DECIMAL(10, 4) NULL,
	-- maybe Airport is at Runway Elevation
	RunwayElevation                         DECIMAL(8, 2) NULL,
	-- maybe Airport has Runway Length
	RunwayLength                            DECIMAL(8, 2) NULL,
	-- maybe Airport has Website URL
	WebsiteURL                              VARCHAR(128) NULL,
	-- Primary index to Airport SAT
	PRIMARY KEY(AirportHID, LoadTime),
	FOREIGN KEY (AirportHID) REFERENCES AirportHUB (AirportHID)
);


CREATE TABLE AssignedAirplaneLINK (
	-- Assigned Airplane LINK surrogate key
	AssignedAirplaneHID                     BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Assigned Airplane involves Airplane
	AirplaneHID                             BIGINT NOT NULL,
	-- Assigned Airplane involves Connection
	ConnectionHID                           BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Assigned Airplane LINK(Airplane, Connection in "Airplane is assigned to Connection")
	UNIQUE(AirplaneHID, ConnectionHID),
	-- Primary index to Assigned Airplane LINK
	PRIMARY KEY(AssignedAirplaneHID),
	FOREIGN KEY (AirplaneHID) REFERENCES AirplaneHUB (AirplaneHID)
);


CREATE TABLE BookingLINK (
	-- Booking LINK surrogate key
	BookingHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Booking involves Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- Booking involves Sales Agent
	SalesAgentHID                           BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Booking LINK(Passenger, Sales Agent in "Passenger books flight with Sales Agent")
	UNIQUE(PassengerHID, SalesAgentHID),
	-- Primary index to Booking LINK
	PRIMARY KEY(BookingHID)
);


CREATE TABLE ConnectionHUB (
	-- Connection HUB surrogate key
	ConnectionHID                           BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Connection involves Airline that has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- Connection involves origin-Airport and Airport has Airport Name
	OriginAirportName                       VARCHAR(48) NOT NULL,
	-- Connection involves destination-Airport and Airport has Airport Name
	DestinationAirportName                  VARCHAR(48) NOT NULL,
	-- Connection involves Flight Number
	FlightNumber                            VARCHAR(12) NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Connection HUB(Airline, Origin Airport, Destination Airport, Flight Number in "Airline flies from origin-Airport to destination-Airport with flight Flight Number")
	UNIQUE(AirlineID, OriginAirportName, DestinationAirportName, FlightNumber),
	-- Primary index to Connection HUB
	PRIMARY KEY(ConnectionHID)
);


CREATE TABLE FixedBaseOperatorLINK (
	-- Fixed Base Operator LINK surrogate key
	FixedBaseOperatorHID                    BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Fixed Base Operator involves Airline
	AirlineHID                              BIGINT NOT NULL,
	-- Fixed Base Operator involves Airport
	AirportHID                              BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Fixed Base Operator LINK(Airline, Airport in "Airline flies from Airport")
	UNIQUE(AirlineHID, AirportHID),
	-- Primary index to Fixed Base Operator LINK
	PRIMARY KEY(FixedBaseOperatorHID),
	FOREIGN KEY (AirlineHID) REFERENCES AirlineHUB (AirlineHID),
	FOREIGN KEY (AirportHID) REFERENCES AirportHUB (AirportHID)
);


CREATE TABLE PartHUB (
	-- Part HUB surrogate key
	PartHID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Part has Part ID
	PartID                                  BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Part HUB(Part ID in "Part has Part ID")
	UNIQUE(PartID),
	-- Primary index to Part HUB
	PRIMARY KEY(PartHID)
);


CREATE TABLE PartSAT (
	-- Part
	PartHID                                 BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Part is built by Manufacturer that has Manufacturer ID
	ManufacturerID                          BIGINT NOT NULL,
	-- Primary index to Part SAT
	PRIMARY KEY(PartHID, LoadTime),
	FOREIGN KEY (PartHID) REFERENCES PartHUB (PartHID)
);


CREATE TABLE PassengerHUB (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Passenger HUB(Passenger ID in "Passenger has Passenger ID")
	UNIQUE(PassengerID),
	-- Primary index to Passenger HUB
	PRIMARY KEY(PassengerHID)
);


CREATE TABLE PassengerSAT (
	-- Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Passenger has Birth Date
	BirthDate                               TIMESTAMP NOT NULL,
	-- Primary index to Passenger SAT
	PRIMARY KEY(PassengerHID, LoadTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PassengerNameSAT (
	-- Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Passenger has Name
	Name                                    VARCHAR(48) NOT NULL,
	-- Primary index to PassengerName SAT
	PRIMARY KEY(PassengerHID, LoadTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PreferredDishSAT (
	-- Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Passenger has Preferred Dish
	PreferredDish                           VARCHAR NOT NULL,
	-- Primary index to PreferredDish SAT
	PRIMARY KEY(PassengerHID, LoadTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE SalesAgentHUB (
	-- Sales Agent HUB surrogate key
	SalesAgentHID                           BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Sales Agent has Sales Agent Name
	SalesAgentName                          VARCHAR(48) NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Natural index to Sales Agent HUB(Sales Agent Name in "Sales Agent has Sales Agent Name")
	UNIQUE(SalesAgentName),
	-- Primary index to Sales Agent HUB
	PRIMARY KEY(SalesAgentHID)
);


ALTER TABLE AirplanePartLINK
	ADD FOREIGN KEY (PartHID) REFERENCES PartHUB (PartHID);

ALTER TABLE AssignedAirplaneLINK
	ADD FOREIGN KEY (ConnectionHID) REFERENCES ConnectionHUB (ConnectionHID);

ALTER TABLE BookingLINK
	ADD FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID);

ALTER TABLE BookingLINK
	ADD FOREIGN KEY (SalesAgentHID) REFERENCES SalesAgentHUB (SalesAgentHID);
