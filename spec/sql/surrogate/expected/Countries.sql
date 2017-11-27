CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE country (
	-- Country has Country Code
	country_code_id                         BIGINT NOT NULL,
	-- Primary index to Country(Country Code in "Country has Country Code")
	PRIMARY KEY(country_code, country_code_id)
);


CREATE TABLE country_code (
	-- Country Code surrogate key
	country_code_id                         BIGSERIAL NOT NULL,
	-- Country Code Value
	country_code_value                      VARCHAR(3) NOT NULL,
	-- Natural index to Country Code
	UNIQUE(country_code_value),
	-- Primary index to Country Code
	PRIMARY KEY(country_code_id)
);


ALTER TABLE country
	ADD FOREIGN KEY (country_code_id) REFERENCES country_code (country_code_id);

