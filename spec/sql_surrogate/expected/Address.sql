CREATE TABLE Company (
	-- Company ID
	CompanyID                               BIGINT IDENTITY NOT NULL,
	-- Company has Company Name
	CompanyName                             VARCHAR NOT NULL,
	-- maybe Company has head office at Address that maybe is at street-Number
	AddressStreetNumber                     VARCHAR(12) NULL,
	-- maybe Company has head office at Address that is at Street that includes first-Street Line
	AddressStreetFirstStreetLine            VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes second-Street Line
	AddressStreetSecondStreetLine           VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes third-Street Line
	AddressStreetThirdStreetLine            VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is in City
	AddressCity                             VARCHAR(64) NULL,
	-- maybe Company has head office at Address that maybe is in Postcode
	AddressPostcode                         VARCHAR NULL CHECK((AddressPostcode >= 1000 AND AddressPostcode <= 9999)),
	-- Primary index to Company
	PRIMARY KEY CLUSTERED(CompanyID),
	-- Unique index to Company over PresenceConstraint over (Company Name in "Company has Company Name") occurs at most one time
	UNIQUE NONCLUSTERED(CompanyName)
);


CREATE TABLE Person (
	-- Person ID
	PersonID                                BIGINT IDENTITY NOT NULL,
	-- Person is of Family that has Family Name
	FamilyName                              VARCHAR(20) NOT NULL,
	-- Person has Given Names
	GivenNames                              VARCHAR(20) NOT NULL,
	-- maybe Person lives at Address that maybe is at street-Number
	AddressStreetNumber                     VARCHAR(12) NULL,
	-- maybe Person lives at Address that is at Street that includes first-Street Line
	AddressStreetFirstStreetLine            VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes second-Street Line
	AddressStreetSecondStreetLine           VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes third-Street Line
	AddressStreetThirdStreetLine            VARCHAR(64) NULL,
	-- maybe Person lives at Address that is in City
	AddressCity                             VARCHAR(64) NULL,
	-- maybe Person lives at Address that maybe is in Postcode
	AddressPostcode                         VARCHAR NULL CHECK((AddressPostcode >= 1000 AND AddressPostcode <= 9999)),
	-- Primary index to Person
	PRIMARY KEY CLUSTERED(PersonID),
	-- Unique index to Person over PresenceConstraint over (Family, Given Names in "Person is of Family", "Person has Given Names") occurs at most one time
	UNIQUE NONCLUSTERED(FamilyName, GivenNames)
);


