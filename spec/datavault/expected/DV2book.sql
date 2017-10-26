CREATE TABLE AirlineHUB (
	-- Airline HUB surrogate key
	AirlineHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Airline has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Airline HUB
	PRIMARY KEY CLUSTERED(AirlineHID),
	-- Unique index to Airline HUB over PresenceConstraint over (Airline ID in "Airline has Airline ID") occurs at most one time
	UNIQUE NONCLUSTERED(AirlineID)
);


CREATE TABLE AirlineSAT (
	-- Airline HUB surrogate key
	AirlineHID                              BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- maybe Airline has Flight Code
	FlightCode                              BIGINT NULL,
	-- Primary index to Airline SAT
	PRIMARY KEY CLUSTERED(AirlineHID, LoadDateTime),
	FOREIGN KEY (AirlineHID) REFERENCES AirlineHUB (AirlineHID)
);


CREATE TABLE AirplaneHUB (
	-- Airplane HUB surrogate key
	AirplaneHID                             BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Airplane has Tail Number
	TailNumber                              VARCHAR(12) NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Airplane HUB
	PRIMARY KEY CLUSTERED(AirplaneHID),
	-- Unique index to Airplane HUB over PresenceConstraint over (Tail Number in "Airplane has Tail Number") occurs one time
	UNIQUE NONCLUSTERED(TailNumber)
);


CREATE TABLE AirplanePartLINK (
	-- Airplane Part LINK surrogate key
	AirplanePartHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Airplane Part involves Airplane
	AirplaneHID                             BIGINT NOT NULL,
	-- Airplane Part involves Part
	PartHID                                 BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Airplane Part LINK
	PRIMARY KEY CLUSTERED(AirplanePartHID),
	-- Unique index to Airplane Part LINK over PresenceConstraint over (Airplane, Part in "Airplane has Part") occurs at most one time
	UNIQUE NONCLUSTERED(AirplaneHID, PartHID),
	FOREIGN KEY (AirplaneHID) REFERENCES AirplaneHUB (AirplaneHID)
);


CREATE TABLE AirportHUB (
	-- Airport HUB surrogate key
	AirportHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Airport has Airport Name
	AirportName                             VARCHAR(48) NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Airport HUB
	PRIMARY KEY CLUSTERED(AirportHID),
	-- Unique index to Airport HUB over PresenceConstraint over (Airport Name in "Airport has Airport Name") occurs at most one time
	UNIQUE NONCLUSTERED(AirportName)
);


CREATE TABLE AirportSAT (
	-- Airport HUB surrogate key
	AirportHID                              BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
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
	PRIMARY KEY CLUSTERED(AirportHID, LoadDateTime),
	FOREIGN KEY (AirportHID) REFERENCES AirportHUB (AirportHID)
);


CREATE TABLE AssignedAirplaneLINK (
	-- Assigned Airplane LINK surrogate key
	AssignedAirplaneHID                     BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Assigned Airplane involves Airplane
	AirplaneHID                             BIGINT NOT NULL,
	-- Assigned Airplane involves Connection
	ConnectionHID                           BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Assigned Airplane LINK
	PRIMARY KEY CLUSTERED(AssignedAirplaneHID),
	-- Unique index to Assigned Airplane LINK over PresenceConstraint over (Airplane, Connection in "Airplane is assigned to Connection") occurs at most one time
	UNIQUE NONCLUSTERED(AirplaneHID, ConnectionHID),
	FOREIGN KEY (AirplaneHID) REFERENCES AirplaneHUB (AirplaneHID)
);


CREATE TABLE BookingLINK (
	-- Booking LINK surrogate key
	BookingHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Booking involves Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- Booking involves Sales Agent
	SalesAgentHID                           BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Booking LINK
	PRIMARY KEY CLUSTERED(BookingHID),
	-- Unique index to Booking LINK over PresenceConstraint over (Passenger, Sales Agent in "Passenger books flight with Sales Agent") occurs at most one time
	UNIQUE NONCLUSTERED(PassengerHID, SalesAgentHID)
);


CREATE TABLE ConnectionHUB (
	-- Connection HUB surrogate key
	ConnectionHID                           BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Connection involves Airline that has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- Connection involves origin-Airport and Airport has Airport Name
	OriginAirportName                       VARCHAR(48) NOT NULL,
	-- Connection involves destination-Airport and Airport has Airport Name
	DestinationAirportName                  VARCHAR(48) NOT NULL,
	-- Connection involves Flight Number
	FlightNumber                            VARCHAR(12) NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Connection HUB
	PRIMARY KEY CLUSTERED(ConnectionHID),
	-- Unique index to Connection HUB over PresenceConstraint over (Airline, Origin Airport, Destination Airport, Flight Number in "Airline flies from origin-Airport to destination-Airport with flight Flight Number") occurs at most one time
	UNIQUE NONCLUSTERED(AirlineID, OriginAirportName, DestinationAirportName, FlightNumber)
);


CREATE TABLE FixedBaseOperatorLINK (
	-- Fixed Base Operator LINK surrogate key
	FixedBaseOperatorHID                    BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Fixed Base Operator involves Airline
	AirlineHID                              BIGINT NOT NULL,
	-- Fixed Base Operator involves Airport
	AirportHID                              BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Fixed Base Operator LINK
	PRIMARY KEY CLUSTERED(FixedBaseOperatorHID),
	-- Unique index to Fixed Base Operator LINK over PresenceConstraint over (Airline, Airport in "Airline flies from Airport") occurs at most one time
	UNIQUE NONCLUSTERED(AirlineHID, AirportHID),
	FOREIGN KEY (AirlineHID) REFERENCES AirlineHUB (AirlineHID),
	FOREIGN KEY (AirportHID) REFERENCES AirportHUB (AirportHID)
);


CREATE TABLE PartHUB (
	-- Part HUB surrogate key
	PartHID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Part has Part ID
	PartID                                  BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Part HUB
	PRIMARY KEY CLUSTERED(PartHID),
	-- Unique index to Part HUB over PresenceConstraint over (Part ID in "Part has Part ID") occurs at most one time
	UNIQUE NONCLUSTERED(PartID)
);


CREATE TABLE PartSAT (
	-- Part HUB surrogate key
	PartHID                                 BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Part is built by Manufacturer that has Manufacturer ID
	ManufacturerID                          BIGINT NOT NULL,
	-- Primary index to Part SAT
	PRIMARY KEY CLUSTERED(PartHID, LoadDateTime),
	FOREIGN KEY (PartHID) REFERENCES PartHUB (PartHID)
);


CREATE TABLE PassengerHUB (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Passenger has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Passenger HUB
	PRIMARY KEY CLUSTERED(PassengerHID),
	-- Unique index to Passenger HUB over PresenceConstraint over (Passenger ID in "Passenger has Passenger ID") occurs at most one time
	UNIQUE NONCLUSTERED(PassengerID)
);


CREATE TABLE PassengerSAT (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Passenger has Birth Date
	BirthDate                               TIMESTAMP NOT NULL,
	-- Primary index to Passenger SAT
	PRIMARY KEY CLUSTERED(PassengerHID, LoadDateTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PassengerNameSAT (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Passenger has Name
	Name                                    VARCHAR(48) NOT NULL,
	-- Primary index to PassengerName SAT
	PRIMARY KEY CLUSTERED(PassengerHID, LoadDateTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PreferredDishSAT (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Passenger has Preferred Dish
	PreferredDish                           VARCHAR NOT NULL,
	-- Primary index to PreferredDish SAT
	PRIMARY KEY CLUSTERED(PassengerHID, LoadDateTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE SalesAgentHUB (
	-- Sales Agent HUB surrogate key
	SalesAgentHID                           BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Sales Agent has Sales Agent Name
	SalesAgentName                          VARCHAR(48) NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Primary index to Sales Agent HUB
	PRIMARY KEY CLUSTERED(SalesAgentHID),
	-- Unique index to Sales Agent HUB over PresenceConstraint over (Sales Agent Name in "Sales Agent has Sales Agent Name") occurs at most one time
	UNIQUE NONCLUSTERED(SalesAgentName)
);


ALTER TABLE AirplanePartLINK
	ADD FOREIGN KEY (PartHID) REFERENCES PartHUB (PartHID);


ALTER TABLE AssignedAirplaneLINK
	ADD FOREIGN KEY (ConnectionHID) REFERENCES ConnectionHUB (ConnectionHID);


ALTER TABLE BookingLINK
	ADD FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID);


ALTER TABLE BookingLINK
	ADD FOREIGN KEY (SalesAgentHID) REFERENCES SalesAgentHUB (SalesAgentHID);

