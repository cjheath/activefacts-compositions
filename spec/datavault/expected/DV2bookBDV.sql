CREATE TABLE AirplanePartManufacturer (
	-- Airplane Part Manufacturer surrogate key
	AirplanePartManufacturerHID             BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airplane Part Manufacturer involves Airplane that has Tail Number
	AirplaneTailNumber                      VARCHAR(12) NOT NULL,
	-- Airplane Part Manufacturer involves Manufacturer that has Manufacturer ID
	ManufacturerID                          BIGINT NOT NULL,
	-- Primary index to Airplane Part Manufacturer
	PRIMARY KEY CLUSTERED(AirplanePartManufacturerHID),
	-- Unique index to Airplane Part Manufacturer over PresenceConstraint over (Airplane, Manufacturer in "Airplane has parts from Manufacturer") occurs at most one time
	UNIQUE NONCLUSTERED(AirplaneTailNumber, ManufacturerID)
);


CREATE TABLE PartHierachy (
	-- Part Hierachy surrogate key
	PartHierachyHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Part Hierachy involves Part that has Part ID
	PartID                                  BIGINT NOT NULL,
	-- Part Hierachy involves parent-Part
	ParentPartHID                           BIGINT NOT NULL,
	-- Primary index to Part Hierachy
	PRIMARY KEY CLUSTERED(PartHierachyHID),
	-- Unique index to Part Hierachy over PresenceConstraint over (Part in "Part is child of parent-Part") occurs at most one time
	UNIQUE NONCLUSTERED(PartID)
);


CREATE TABLE PassengerPIT (
	-- Passenger PIT surrogate key
	PassengerPITHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- PassengerName LoadDateTime
	PassengerNameLoadDateTime               TIMESTAMP,
	-- SnapshotDateTime
	SnapshotDateTime                        TIMESTAMP,
	-- Passenger PIT surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- Passenger PIT surrogate key
	PassengerNameHID                        BIGINT NOT NULL,
	-- Primary index to Passenger PIT
	PRIMARY KEY CLUSTERED(PassengerPITHID),
	-- Unique index to Passenger PIT
	UNIQUE NONCLUSTERED(PassengerHID, SnapshotDateTime)
);


CREATE TABLE PassengerSalesAgentBRIDGE (
	-- Passenger Sales Agent BRIDGE surrogate key
	PassengerSalesAgentHID                  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger Sales Agent involves Passenger that has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- Passenger Sales Agent involves Sales Agent that has Sales Agent Name
	SalesAgentName                          VARCHAR(48) NOT NULL,
	-- Primary index to Passenger Sales Agent BRIDGE
	PRIMARY KEY CLUSTERED(PassengerSalesAgentHID),
	-- Unique index to Passenger Sales Agent BRIDGE over PresenceConstraint over (Passenger, Sales Agent in "Passenger books a flight with Sales Agent") occurs at most one time
	UNIQUE NONCLUSTERED(PassengerID, SalesAgentName)
);


CREATE TABLE PassengerSameAs (
	-- Passenger Same As surrogate key
	PassengerSameAsHID                      BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger Same As involves Passenger that has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- Passenger Same As involves master-Passenger
	MasterPassengerHID                      BIGINT NOT NULL,
	-- Primary index to Passenger Same As
	PRIMARY KEY CLUSTERED(PassengerSameAsHID),
	-- Unique index to Passenger Same As over PresenceConstraint over (Passenger in "Passenger is same as master-Passenger") occurs at most one time
	UNIQUE NONCLUSTERED(PassengerID)
);


CREATE TABLE Service (
	-- Service surrogate key
	ServiceHID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Service involves Airline that has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- Service involves origin-Airport and Airport has Airport Name
	OriginAirportName                       VARCHAR(48) NOT NULL,
	-- Service involves destination-Airport and Airport has Airport Name
	DestinationAirportName                  VARCHAR(48) NOT NULL,
	-- Primary index to Service
	PRIMARY KEY CLUSTERED(ServiceHID),
	-- Unique index to Service over PresenceConstraint over (Airline, Origin Airport, Destination Airport in "Airline flies from origin-Airport to destination-Airport") occurs at most one time
	UNIQUE NONCLUSTERED(AirlineID, OriginAirportName, DestinationAirportName)
);


