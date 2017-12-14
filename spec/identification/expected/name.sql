CREATE TABLE Thing (
	-- Thing has Thing Name
	ThingName                               VARCHAR NOT NULL,
	-- Primary index to Thing(Thing Name in "Thing has Thing Name")
	PRIMARY KEY CLUSTERED(ThingName)
)
GO


CREATE TABLE Thong (
	-- Thong has Thing that has Thing Name
	ThingName                               VARCHAR NOT NULL,
	-- Primary index to Thong(Thing in "Thong has Thing")
	PRIMARY KEY CLUSTERED(ThingName),
	FOREIGN KEY (ThingName) REFERENCES Thing (ThingName)
)
GO


