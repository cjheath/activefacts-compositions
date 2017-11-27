CREATE TABLE AirplanePartManufacturerExplorationLINK (
	-- Airplane Part Manufacturer Exploration LINK surrogate key
	AirplanePartManufacturerExplorationHID  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Airplane Part Manufacturer Exploration involves Airplane
	AirplaneHID                             BIGINT NOT NULL,
	-- Airplane Part Manufacturer Exploration involves Manufacturer
	ManufacturerHID                         BIGINT NOT NULL,
	-- Natural index to Airplane Part Manufacturer Exploration LINK(Airplane, Manufacturer in "Airplane has parts from Manufacturer")
	UNIQUE(AirplaneHID, ManufacturerHID),
	-- Primary index to Airplane Part Manufacturer Exploration LINK
	PRIMARY KEY(AirplanePartManufacturerExplorationHID),
	FOREIGN KEY (AirplaneHID) REFERENCES AirplaneHUB (AirplaneHID),
	FOREIGN KEY (ManufacturerHID) REFERENCES ManufacturerHUB (ManufacturerHID)
);


CREATE TABLE PartHierarchyLINK (
	-- Part Hierarchy LINK surrogate key
	PartHierarchyHID                        BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Part Hierarchy involves Part
	PartHID                                 BIGINT NOT NULL,
	-- Part Hierarchy involves parent-Part
	ParentPartHID                           BIGINT NOT NULL,
	-- Natural index to Part Hierarchy LINK(Part in "Part is child of parent-Part")
	UNIQUE(PartHID),
	-- Primary index to Part Hierarchy LINK
	PRIMARY KEY(PartHierarchyHID),
	FOREIGN KEY (ParentPartHID) REFERENCES PartHUB (PartHID),
	FOREIGN KEY (PartHID) REFERENCES PartHUB (PartHID)
);


CREATE TABLE PassengerPIT (
	-- Passenger PIT surrogate key
	PassengerPITHID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- PassengerName SAT Load DateTime
	PassengerNameSATLoadDateTime            TIMESTAMP,
	-- PreferredDish SAT Load DateTime
	PreferredDishSATLoadDateTime            TIMESTAMP,
	-- Snapshot DateTime
	SnapshotDateTime                        TIMESTAMP,
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- PassengerName SAT surrogate key
	PassengerNameSATHID                     BIGINT NOT NULL,
	-- PreferredDish SAT surrogate key
	PreferredDishSATHID                     BIGINT NOT NULL,
	-- Natural index to Passenger PIT
	UNIQUE(PassengerHID, SnapshotDateTime),
	-- Primary index to Passenger PIT
	PRIMARY KEY(PassengerPITHID),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (PassengerNameSATHID, PassengerNameSATLoadDateTime) REFERENCES PassengerNameSAT (PassengerHID, LoadTime),
	FOREIGN KEY (PreferredDishSATHID, PreferredDishSATLoadDateTime) REFERENCES PreferredDishSAT (PassengerHID, LoadTime)
);


CREATE TABLE PassengerSalesAgentBRIDGE (
	-- Passenger Sales Agent BRIDGE surrogate key
	PassengerSalesAgentHID                  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger Sales Agent involves Passenger that has Passenger ID
	PassengerID                             BIGINT NOT NULL,
	-- Passenger Sales Agent involves Sales Agent that has Sales Agent Name
	SalesAgentName                          VARCHAR(48) NOT NULL,
	-- Natural index to Passenger Sales Agent BRIDGE(Passenger, Sales Agent in "Passenger books a flight with Sales Agent")
	UNIQUE(PassengerID, SalesAgentName),
	-- Primary index to Passenger Sales Agent BRIDGE
	PRIMARY KEY(PassengerSalesAgentHID),
	FOREIGN KEY (PassengerID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (SalesAgentName) REFERENCES SalesAgentHUB (SalesAgentHID)
);


CREATE TABLE PassengerSameAsLINK (
	-- Passenger Same As LINK surrogate key
	PassengerSameAsHID                      BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Passenger Same As involves Passenger
	PassengerHID                            BIGINT NOT NULL,
	-- Passenger Same As involves master-Passenger
	MasterPassengerHID                      BIGINT NOT NULL,
	-- Natural index to Passenger Same As LINK(Passenger in "Passenger is same as master-Passenger")
	UNIQUE(PassengerHID),
	-- Primary index to Passenger Same As LINK
	PRIMARY KEY(PassengerSameAsHID),
	FOREIGN KEY (MasterPassengerHID) REFERENCES PassengerHUB (PassengerHID),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE PassengerComputedSAT (
	-- Passenger HUB surrogate key
	PassengerHID                            BIGINT NOT NULL,
	-- LoadTime
	LoadTime                                TIMESTAMP,
	-- RecordSource
	RecordSource                            VARCHAR NOT NULL,
	-- Passenger has Age
	Age                                     INTEGER NOT NULL,
	-- Primary index to PassengerComputed SAT
	PRIMARY KEY(PassengerHID, LoadTime),
	FOREIGN KEY (PassengerHID) REFERENCES PassengerHUB (PassengerHID)
);


CREATE TABLE ServiceComputedLINK (
	-- Service Computed LINK surrogate key
	ServiceComputedHID                      BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Service Computed involves Airline
	AirlineHID                              BIGINT NOT NULL,
	-- Service Computed involves origin-Airport
	OriginAirportHID                        BIGINT NOT NULL,
	-- Service Computed involves destination-Airport
	DestinationAirportHID                   BIGINT NOT NULL,
	-- Natural index to Service Computed LINK(Airline, Origin Airport, Destination Airport in "Airline flies from origin-Airport to destination-Airport")
	UNIQUE(AirlineHID, OriginAirportHID, DestinationAirportHID),
	-- Primary index to Service Computed LINK
	PRIMARY KEY(ServiceComputedHID),
	FOREIGN KEY (AirlineHID) REFERENCES AirlineHUB (AirlineHID),
	FOREIGN KEY (DestinationAirportHID) REFERENCES AirportHUB (AirportHID),
	FOREIGN KEY (OriginAirportHID) REFERENCES AirportHUB (AirportHID)
);


