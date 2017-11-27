CREATE TABLE PERSON (
	-- Person has family-Name
	FAMILY_NAME                             VARCHAR NOT NULL,
	-- Person has given-Name
	GIVEN_NAME                              VARCHAR NOT NULL,
	-- Primary index to Person(Family Name, Given Name in "Person has family-Name", "Person has given-Name")
	PRIMARY KEY(FAMILY_NAME, GIVEN_NAME)
);


