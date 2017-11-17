CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE company (
	-- Company is a kind of Party that has Party ID
	party_id                                BIGINT NOT NULL,
	-- Primary index to Company over PresenceConstraint over (Party in "Company is a kind of Party") occurs at most one time
	PRIMARY KEY(party_id)
);


CREATE TABLE party (
	-- Party has Party ID
	party_id                                BIGSERIAL NOT NULL,
	-- Party is of Party Type that has Party Type Code
	party_type_code                         VARCHAR(16) NOT NULL CHECK(party_type_code = 'Company' OR party_type_code = 'Person'),
	-- Primary index to Party over PresenceConstraint over (Party ID in "Party has Party ID") occurs at most one time
	PRIMARY KEY(party_id)
);


CREATE TABLE person (
	-- Person is a kind of Party that has Party ID
	party_id                                BIGINT NOT NULL,
	-- Primary index to Person over PresenceConstraint over (Party in "Person is a kind of Party") occurs at most one time
	PRIMARY KEY(party_id),
	FOREIGN KEY (party_id) REFERENCES party (party_id)
);


ALTER TABLE company
	ADD FOREIGN KEY (party_id) REFERENCES party (party_id);

