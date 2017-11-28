CREATE TABLE Person (
	-- Person has family-Name
	FamilyName                              VARCHAR NOT NULL,
	-- Person has given-Name
	GivenName                               VARCHAR NOT NULL,
	-- Primary index to Person(Family Name, Given Name in "Person has family-Name", "Person has given-Name")
	PRIMARY KEY(FamilyName, GivenName)
);


