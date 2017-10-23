--
-- Relational Schema for test Information Model
-- Generated by ActiveFacts Schema Generator at 2016-10-16T11:04:29+11:00.
--

CREATE TABLE Country (
	-- Country has Country Code
	CountryCode                             CHARACTER(3) NOT NULL,
	-- Primary index to Country over PresenceConstraint over (Country Code in "Country has Country Code") occurs at most one time
	PRIMARY KEY CLUSTERED(CountryCode, CountryCode)
);


CREATE TABLE CountryCode (
	-- Country Code Value
	CountryCodeValue                        CHARACTER(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY CLUSTERED(CountryCodeValue)
);


ALTER TABLE Country
	ADD FOREIGN KEY (CountryCode) REFERENCES CountryCode (CountryCodeValue);

