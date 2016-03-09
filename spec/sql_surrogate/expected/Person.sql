CREATE TABLE Person (
	-- Person ID
	PersonID                                BIGINT IDENTITY NOT NULL,
	-- Person has family-Name
	FamilyName                              VARCHAR NOT NULL,
	-- Person has given-Name
	GivenName                               VARCHAR NOT NULL,
	-- Primary index to Person
	PRIMARY KEY CLUSTERED(PersonID),
	-- Unique index to Person over PresenceConstraint over (Family Name, Given Name in "Person has family-Name", "Person has given-Name") occurs at most one time
	UNIQUE NONCLUSTERED(FamilyName, GivenName)
);


