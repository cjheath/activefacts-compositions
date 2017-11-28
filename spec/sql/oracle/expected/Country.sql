CREATE TABLE COUNTRY (
	-- Country has ISO3166Code3
	ISO3166_CODE3                           VARCHAR(3) NOT NULL,
	-- Country is called Country Name
	COUNTRY_NAME                            VARCHAR(60) NOT NULL,
	-- Country has ISO3166Code2
	ISO3166_CODE2                           VARCHAR(2) NOT NULL,
	-- Country has ISO3166Numeric3
	ISO3166_NUMERIC3                        INTEGER NOT NULL,
	-- Primary index to Country(ISO3166Code3 in "Country has ISO3166Code3")
	PRIMARY KEY(ISO3166_CODE3),
	-- Unique index to Country(Country Name in "Country is called Country Name")
	UNIQUE(COUNTRY_NAME),
	-- Unique index to Country(ISO3166Code2 in "Country has ISO3166Code2")
	UNIQUE(ISO3166_CODE2),
	-- Unique index to Country(ISO3166Numeric3 in "Country has ISO3166Numeric3")
	UNIQUE(ISO3166_NUMERIC3)
);


