CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;

CREATE TABLE company (
	-- Company surrogate key
	company_id                              BIGSERIAL NOT NULL,
	-- Company has Company Name
	company_name                            VARCHAR NOT NULL,
	-- maybe Company has head office at Address that maybe is at street-Number
	address_street_number                   VARCHAR(12) NULL,
	-- maybe Company has head office at Address that is at Street that includes first-Street Line
	address_street_first_street_line        VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes second-Street Line
	address_street_second_street_line       VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is at Street that maybe includes third-Street Line
	address_street_third_street_line        VARCHAR(64) NULL,
	-- maybe Company has head office at Address that is in City
	address_city                            VARCHAR(64) NULL,
	-- maybe Company has head office at Address that maybe is in Postcode
	address_postcode                        VARCHAR NULL CHECK((address_postcode >= 1000 AND address_postcode <= 9999)),
	-- Natural index to Company(Company Name in "Company has Company Name")
	UNIQUE(company_name),
	-- Primary index to Company
	PRIMARY KEY(company_id)
);


CREATE TABLE person (
	-- Person surrogate key
	person_id                               BIGSERIAL NOT NULL,
	-- Person is of Family that has Family Name
	family_name                             VARCHAR(20) NOT NULL,
	-- Person has Given Names
	given_names                             VARCHAR(20) NOT NULL,
	-- maybe Person lives at Address that maybe is at street-Number
	address_street_number                   VARCHAR(12) NULL,
	-- maybe Person lives at Address that is at Street that includes first-Street Line
	address_street_first_street_line        VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes second-Street Line
	address_street_second_street_line       VARCHAR(64) NULL,
	-- maybe Person lives at Address that is at Street that maybe includes third-Street Line
	address_street_third_street_line        VARCHAR(64) NULL,
	-- maybe Person lives at Address that is in City
	address_city                            VARCHAR(64) NULL,
	-- maybe Person lives at Address that maybe is in Postcode
	address_postcode                        VARCHAR NULL CHECK((address_postcode >= 1000 AND address_postcode <= 9999)),
	-- Natural index to Person(Family, Given Names in "Person is of Family", "Person has Given Names")
	UNIQUE(family_name, given_names),
	-- Primary index to Person
	PRIMARY KEY(person_id)
);


