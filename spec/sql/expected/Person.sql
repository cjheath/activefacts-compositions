CREATE TABLE Person (
	-- Person has family-Name
	FamilyName                              VARCHAR NOT NULL,
	-- Person has given-Name
	GivenName                               VARCHAR NOT NULL,
	-- Primary index to Person over PresenceConstraint over (Family Name, Given Name in "Person has family-Name", "Person has given-Name") occurs at most one time
	PRIMARY KEY(FamilyName, GivenName)
);


