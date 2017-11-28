CREATE TABLE Company (
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
	-- Primary index to Company(Company Name in "Company has Company Name")
	PRIMARY KEY(CompanyName)
);


CREATE TABLE Person (
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
	-- Primary index to Person(Family, Given Names in "Person is of Family", "Person has Given Names")
	PRIMARY KEY(FamilyName, GivenNames)
);


