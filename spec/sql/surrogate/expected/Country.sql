CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE country (
	-- Country surrogate key
	country_id                              BIGSERIAL NOT NULL,
	-- Country has ISO3166Code3
	iso3166_code3                           VARCHAR(3) NOT NULL,
	-- Country is called Country Name
	country_name                            VARCHAR(60) NOT NULL,
	-- Country has ISO3166Code2
	iso3166_code2                           VARCHAR(2) NOT NULL,
	-- Country has ISO3166Numeric3
	iso3166_numeric3                        INTEGER NOT NULL,
	-- Natural index to Country(ISO3166Code3 in "Country has ISO3166Code3")
	UNIQUE(iso3166_code3),
	-- Primary index to Country
	PRIMARY KEY(country_id),
	-- Unique index to Country(Country Name in "Country is called Country Name")
	UNIQUE(country_name),
	-- Unique index to Country(ISO3166Code2 in "Country has ISO3166Code2")
	UNIQUE(iso3166_code2),
	-- Unique index to Country(ISO3166Numeric3 in "Country has ISO3166Numeric3")
	UNIQUE(iso3166_numeric3)
);


