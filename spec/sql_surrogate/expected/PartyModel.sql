CREATE TABLE Company (
	-- Company is a kind of Party that has Party ID
	PartyID                                 BIGINT NOT NULL,
	-- Primary index to Company over PresenceConstraint over (Party in "Company is a kind of Party") occurs at most one time
	PRIMARY KEY CLUSTERED(PartyID)
);


CREATE TABLE Party (
	-- Party has Party ID
	PartyID                                 BIGINT IDENTITY NOT NULL,
	-- Party is of Party Type that has Party Type Code
	PartyTypeCode                           VARCHAR(16) NOT NULL CHECK(PartyTypeCode = 'Company' OR PartyTypeCode = 'Person'),
	-- Primary index to Party over PresenceConstraint over (Party ID in "Party has Party ID") occurs at most one time
	PRIMARY KEY CLUSTERED(PartyID)
);


CREATE TABLE Person (
	-- Person is a kind of Party that has Party ID
	PartyID                                 BIGINT NOT NULL,
	-- Primary index to Person over PresenceConstraint over (Party in "Person is a kind of Party") occurs at most one time
	PRIMARY KEY CLUSTERED(PartyID),
	FOREIGN KEY (PartyID) REFERENCES Party (PartyID)
);


ALTER TABLE Company
	ADD FOREIGN KEY (PartyID) REFERENCES Party (PartyID);

