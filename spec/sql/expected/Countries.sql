CREATE TABLE Country (
	-- Country Code
	CountryCode                             char(3) NULL,
	-- Primary index to Country over PresenceConstraint over (Country Code in "Country has Country Code") occurs at most one time
	PRIMARY KEY CLUSTERED(CountryCode, CountryCode)
)
GO

CREATE TABLE CountryCode (
	-- Country Code Value
	CountryCodeValue                        char(3) NULL,
	-- Primary index to Country Code
	PRIMARY KEY CLUSTERED(CountryCodeValue)
)
GO

ALTER TABLE CountryCode
	ADD FOREIGN KEY (CountryCode) REFERENCES CountryCode (CountryCodeValue)
GO