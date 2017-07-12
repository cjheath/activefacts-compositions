CREATE TABLE AirplanePartManufacturerExplorationLINK (
	-- Airplane Part Manufacturer Exploration LINK surrogate key
	AirplanePartManufacturerExplorationHID  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airplane Part Manufacturer Exploration involves Airplane that has Tail Number
	AirplaneTailNumber                      VARCHAR(12) NOT NULL,
	-- Airplane Part Manufacturer Exploration involves Manufacturer that has Manufacturer ID
	ManufacturerID                          BIGINT NOT NULL,
	-- Primary index to Airplane Part Manufacturer Exploration LINK
	PRIMARY KEY CLUSTERED(AirplanePartManufacturerExplorationHID),
	-- Unique index to Airplane Part Manufacturer Exploration LINK over PresenceConstraint over (Airplane, Manufacturer in "Airplane has parts from Manufacturer") occurs at most one time
	UNIQUE NONCLUSTERED(AirplaneTailNumber, ManufacturerID),
	FOREIGN KEY (AirplaneTailNumber) REFERENCES AirplaneHUB (AirplaneHID),
	FOREIGN KEY (ManufacturerID) REFERENCES ManufacturerHUB (ManufacturerHID)
);


CREATE TABLE PartHierarchyLINK (
	-- Part Hierarchy LINK surrogate key
	PartHierarchyHID                        BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Part Hierarchy involves Part that has Part ID
	PartID                                  BIGINT NOT NULL,
	-- Part Hierarchy involves parent-Part
	ParentPartHID                           BIGINT NOT NULL,
	-- Primary index to Part Hierarchy LINK
	PRIMARY KEY CLUSTERED(PartHierarchyHID),
	-- Unique index to Part Hierarchy LINK over PresenceConstraint over (Part in "Part is child of parent-Part") occurs at most one time
	UNIQUE NONCLUSTERED(PartID),
	FOREIGN KEY (ParentPartHID) REFERENCES PartHUB (PartHID),
	FOREIGN KEY (PartID) REFERENCES PartHUB (PartHID)
);


CREATE TABLE PassengerPIT (
	-- Passenger PIT surrogate key
	PassengerPITHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- PassengerName SAT LoadDateTime
	PassengerNameSATLoadDateTime            TIMESTAMP,
	-- PreferredDish SAT LoadDateTime
	PreferredDishSATLoadDateTime            TIMESTAMP,
	-- SnapshotDateTime
	SnapshotDateTime                        TIMESTAMP,
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- PassengerName SAT surrogate key
	PassengerNameSATHID                     BIGINT NOT NULL,
	-- PreferredDish SAT surrogate key
	PreferredDishSATHID                     BIGINT NOT NULL,
	-- Primary index to Passenger PIT
	PRIMARY KEY CLUSTERED(PassengerPITHID),
	-- Unique index to Passenger PIT
	UNIQUE NONCLUSTERED(PassengerHID, SnapshotDateTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (PassengerNameSATHID, PassengerNameSATLoadDateTime) REFERENCES PassengerNameSAT (PassengerHID, LoadDateTime),
	FOREIGN KEY (PreferredDishSATHID, PreferredDishSATLoadDateTime) REFERENCES PreferredDishSAT (PassengerHID, LoadDateTime)
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
	UNIQUE NONCLUSTERED(PassengerID, SalesAgentName),
	FOREIGN KEY (PassengerID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (SalesAgentName) REFERENCES SalesAgentHUB (SalesAgentHID)
);


CREATE TABLE PassengerSameAsLINK (
	-- Passenger Same As LINK surrogate key
	PassengerSameAsHID                      BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger Same As involves Passenger that has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- Passenger Same As involves master-Passenger
	MasterPassengerHID                      BIGINT NOT NULL,
	-- Primary index to Passenger Same As LINK
	PRIMARY KEY CLUSTERED(PassengerSameAsHID),
	-- Unique index to Passenger Same As LINK over PresenceConstraint over (Passenger in "Passenger is same as master-Passenger") occurs at most one time
	UNIQUE NONCLUSTERED(PassengerID),
	FOREIGN KEY (MasterPassengerHID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (PassengerID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PassengerComputedSAT (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- LoadDateTime
	LoadDateTime                            TIMESTAMP,
	-- Passenger has Age
	Age                                     INTEGER NOT NULL,
	-- Primary index to PassengerComputed SAT
	PRIMARY KEY CLUSTERED(PassengerHID, LoadDateTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE ServiceComputedLINK (
	-- Service Computed LINK surrogate key
	ServiceComputedHID                      BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Service Computed involves Airline that has Airline ID
	AirlineID                               BIGINT NOT NULL,
	-- Service Computed involves origin-Airport and Airport has Airport Name
	OriginAirportName                       VARCHAR(48) NOT NULL,
	-- Service Computed involves destination-Airport and Airport has Airport Name
	DestinationAirportName                  VARCHAR(48) NOT NULL,
	-- Primary index to Service Computed LINK
	PRIMARY KEY CLUSTERED(ServiceComputedHID),
	-- Unique index to Service Computed LINK over PresenceConstraint over (Airline, Origin Airport, Destination Airport in "Airline flies from origin-Airport to destination-Airport") occurs at most one time
	UNIQUE NONCLUSTERED(AirlineID, OriginAirportName, DestinationAirportName),
	FOREIGN KEY (AirlineID) REFERENCES AirlineHUB (AirlineHID),
	FOREIGN KEY (DestinationAirportName) REFERENCES AirportHUB (AirportHID),
	FOREIGN KEY (OriginAirportName) REFERENCES AirportHUB (AirportHID)
);


