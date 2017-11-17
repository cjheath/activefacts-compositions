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
	-- Primary index to Country
	PRIMARY KEY(country_id),
	-- Unique index to Country over PresenceConstraint over (Country Name in "Country is called Country Name") occurs at most one time
	UNIQUE(country_name),
	-- Unique index to Country over PresenceConstraint over (ISO3166Code2 in "Country has ISO3166Code2") occurs one time
	UNIQUE(iso3166_code2),
	-- Unique index to Country over PresenceConstraint over (ISO3166Code3 in "Country has ISO3166Code3") occurs at most one time
	UNIQUE(iso3166_code3),
	-- Unique index to Country over PresenceConstraint over (ISO3166Numeric3 in "Country has ISO3166Numeric3") occurs one time
	UNIQUE(iso3166_numeric3)
);


