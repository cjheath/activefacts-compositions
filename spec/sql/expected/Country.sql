CREATE TABLE Country (
	-- Country has ISO3166Code3
	ISO3166Code3                            VARCHAR(3) NOT NULL,
	-- Country is called Country Name
	CountryName                             VARCHAR(60) NOT NULL,
	-- Country has ISO3166Code2
	ISO3166Code2                            VARCHAR(2) NOT NULL,
	-- Country has ISO3166Numeric3
	ISO3166Numeric3                         INTEGER NOT NULL,
	-- Primary index to Country(ISO3166Code3 in "Country has ISO3166Code3")
	PRIMARY KEY(ISO3166Code3),
	-- Unique index to Country(Country Name in "Country is called Country Name")
	UNIQUE(CountryName),
	-- Unique index to Country(ISO3166Code2 in "Country has ISO3166Code2")
	UNIQUE(ISO3166Code2),
	-- Unique index to Country(ISO3166Numeric3 in "Country has ISO3166Numeric3")
	UNIQUE(ISO3166Numeric3)
);


