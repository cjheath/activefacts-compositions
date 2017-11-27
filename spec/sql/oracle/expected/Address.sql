CREATE TABLE COMPANY (
	-- Company has Company Name
	COMPANY_NAME                            VARCHAR NOT NULL,
	-- maybe Company has head office at Address that maybe is at street-Number
	ADDRESS_STREET_NUMBER                   VARCHAR(12) NULL,
	-- maybe Company has head office at Address that is at Street that includes first-Street Line
	ADDRESS_STREET_FIRST_STREET_LINE        VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes second-Street Line
	ADDRESS_STREET_SECOND_STREET_LINE       VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes third-Street Line
	ADDRESS_STREET_THIRD_STREET_LINE        VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is in City
	ADDRESS_CITY                            VARCHAR(64) NULL,
	-- maybe Company has head office at Address that maybe is in Postcode
	ADDRESS_POSTCODE                        VARCHAR NULL CHECK((ADDRESS_POSTCODE >= 1000 AND ADDRESS_POSTCODE <= 9999)),
	-- Primary index to Company(Company Name in "Company has Company Name")
	PRIMARY KEY(COMPANY_NAME)
);


CREATE TABLE PERSON (
	-- Person is of Family that has Family Name
	FAMILY_NAME                             VARCHAR(20) NOT NULL,
	-- Person has Given Names
	GIVEN_NAMES                             VARCHAR(20) NOT NULL,
	-- maybe Person lives at Address that maybe is at street-Number
	ADDRESS_STREET_NUMBER                   VARCHAR(12) NULL,
	-- maybe Person lives at Address that is at Street that includes first-Street Line
	ADDRESS_STREET_FIRST_STREET_LINE        VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes second-Street Line
	ADDRESS_STREET_SECOND_STREET_LINE       VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes third-Street Line
	ADDRESS_STREET_THIRD_STREET_LINE        VARCHAR(64) NULL,
	-- maybe Person lives at Address that is in City
	ADDRESS_CITY                            VARCHAR(64) NULL,
	-- maybe Person lives at Address that maybe is in Postcode
	ADDRESS_POSTCODE                        VARCHAR NULL CHECK((ADDRESS_POSTCODE >= 1000 AND ADDRESS_POSTCODE <= 9999)),
	-- Primary index to Person(Family, Given Names in "Person is of Family", "Person has Given Names")
	PRIMARY KEY(FAMILY_NAME, GIVEN_NAMES)
);


