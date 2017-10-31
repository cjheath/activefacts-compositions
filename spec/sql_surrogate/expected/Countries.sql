CREATE TABLE Country (
	-- Country has Country Code
	CountryCodeID                           BIGINT NOT NULL,
	-- Primary index to Country over PresenceConstraint over (Country Code in "Country has Country Code") occurs at most one time
	PRIMARY KEY(CountryCode, CountryCodeID)
);


CREATE TABLE CountryCode (
	-- Country Code surrogate key
	CountryCodeID                           BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Country Code Value
	CountryCodeValue                        CHARACTER(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY(CountryCodeID),
	-- Unique index to Country Code
	UNIQUE(CountryCodeValue)
);


ALTER TABLE Country
	ADD FOREIGN KEY (CountryCodeID) REFERENCES CountryCode (CountryCodeID);

