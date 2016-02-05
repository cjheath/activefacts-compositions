CREATE TABLE Person (
	-- Person has family-Name
	FamilyName                              varchar NULL,
	-- Person has given-Name
	GivenName                               varchar NULL,
	-- Primary index to Person over PresenceConstraint over (Family Name, Given Name in "Person has family-Name", "Person has given-Name") occurs at most one time
	PRIMARY KEY CLUSTERED(FamilyName, GivenName)
)
GO

