CREATE TABLE Country (
	-- Country Code ID
	CountryCodeID                           BIGINT NOT NULL,
	-- Primary index to Country over PresenceConstraint over (Country Code in "Country has Country Code") occurs at most one time
	PRIMARY KEY CLUSTERED(CountryCode, CountryCodeID)
);


CREATE TABLE CountryCode (
	-- Country Code ID
	CountryCodeID                           BIGINT IDENTITY NOT NULL,
	-- Country Code Value
	CountryCodeValue                        CHARACTER(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY CLUSTERED(CountryCodeID),
	-- Unique index to Country Code
	UNIQUE NONCLUSTERED(CountryCodeValue)
);


ALTER TABLE Country
	ADD FOREIGN KEY (CountryCodeID) REFERENCES CountryCode (CountryCodeID);

