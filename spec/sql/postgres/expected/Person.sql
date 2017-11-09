CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE person (
	-- Person has family-Name
	family_name                             VARCHAR NOT NULL,
	-- Person has given-Name
	given_name                              VARCHAR NOT NULL,
	-- Primary index to Person over PresenceConstraint over (Family Name, Given Name in "Person has family-Name", "Person has given-Name") occurs at most one time
	PRIMARY KEY(family_name, given_name)
);


