CREATE TABLE Country (
	-- Country ID
	CountryID                               BIGINT IDENTITY NOT NULL,
	-- Country has ISO3166Code3
	ISO3166Code3                            varchar(3) NULL,
	-- Country is called Country Name
	CountryName                             varchar(60) NULL,
	-- Country has ISO3166Code2
	ISO3166Code2                            varchar(2) NULL,
	-- Country has ISO3166Numeric3
	ISO3166Numeric3                         Integer NULL,
	-- Primary index to Country
	PRIMARY KEY CLUSTERED(CountryID),
	-- Unique index to Country over PresenceConstraint over (Country Name in "Country is called Country Name") occurs at most one time
	UNIQUE NONCLUSTERED(CountryName),
	-- Unique index to Country over PresenceConstraint over (ISO3166Code2 in "Country has ISO3166Code2") occurs one time
	UNIQUE NONCLUSTERED(ISO3166Code2),
	-- Unique index to Country over PresenceConstraint over (ISO3166Code3 in "Country has ISO3166Code3") occurs at most one time
	UNIQUE NONCLUSTERED(ISO3166Code3),
	-- Unique index to Country over PresenceConstraint over (ISO3166Numeric3 in "Country has ISO3166Numeric3") occurs one time
	UNIQUE NONCLUSTERED(ISO3166Numeric3)
)
GO

