CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE person (
	-- Person surrogate key
	person_id                               BIGSERIAL NOT NULL,
	-- Person has family-Name
	family_name                             VARCHAR NOT NULL,
	-- Person has given-Name
	given_name                              VARCHAR NOT NULL,
	-- Natural index to Person(Family Name, Given Name in "Person has family-Name", "Person has given-Name")
	UNIQUE(family_name, given_name),
	-- Primary index to Person
	PRIMARY KEY(person_id)
);


