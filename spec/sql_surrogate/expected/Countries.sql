CREATE TABLE Country (
	-- Country Code ID
	CountryCodeID                           BIGINT IDENTITY NOT NULL,
	-- Primary index to Country over PresenceConstraint over (Country Code in "Country has Country Code") occurs at most one time
	PRIMARY KEY CLUSTERED(CountryCode, CountryCodeID)
)
GO

CREATE TABLE CountryCode (
	-- Country Code ID
	CountryCodeID                           BIGINT IDENTITY NOT NULL,
	-- Country Code Value
	CountryCodeValue                        char(3) NULL,
	-- Primary index to Country Code
	PRIMARY KEY CLUSTERED(CountryCodeID),
	-- Unique index to Country Code
	UNIQUE NONCLUSTERED(CountryCodeValue)
)
GO

ALTER TABLE CountryCode
	ADD FOREIGN KEY (CountryCodeID) REFERENCES CountryCode (CountryCodeID)
GO
