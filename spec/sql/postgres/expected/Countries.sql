CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE country (
	-- Country has Country Code
	country_code                            VARCHAR(3) NOT NULL,
	-- Primary index to Country(Country Code in "Country has Country Code")
	PRIMARY KEY(country_code, country_code)
);


CREATE TABLE country_code (
	-- Country Code Value
	country_code_value                      VARCHAR(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY(country_code_value)
);


ALTER TABLE country
	ADD FOREIGN KEY (country_code) REFERENCES country_code (country_code_value);

