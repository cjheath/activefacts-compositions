CREATE TABLE Company (
	-- Company is a kind of Party that has Party ID
	PartyID                                 BIGINT NOT NULL,
	-- Primary index to Company(Party in "Company is a kind of Party")
	PRIMARY KEY(PartyID)
);


CREATE TABLE Party (
	-- Party has Party ID
	PartyID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Party is of Party Type that has Party Type Code
	PartyTypeCode                           VARCHAR(16) NOT NULL CHECK(PartyTypeCode = 'Company' OR PartyTypeCode = 'Person'),
	-- Primary index to Party(Party ID in "Party has Party ID")
	PRIMARY KEY(PartyID)
);


CREATE TABLE Person (
	-- Person is a kind of Party that has Party ID
	PartyID                                 BIGINT NOT NULL,
	-- Primary index to Person(Party in "Person is a kind of Party")
	PRIMARY KEY(PartyID),
	FOREIGN KEY (PartyID) REFERENCES Party (PartyID)
);


ALTER TABLE Company
	ADD FOREIGN KEY (PartyID) REFERENCES Party (PartyID);
