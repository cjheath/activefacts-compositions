CREATE TABLE Thing (
	-- Thing has Thing ID
	ThingID                                 BIGINT NOT NULL IDENTITY,
	-- Primary index to Thing(Thing ID in "Thing has Thing ID")
	PRIMARY KEY CLUSTERED(ThingID)
)
GO


CREATE TABLE Thong (
	-- Thong has Thing that has Thing ID
	ThingID                                 BIGINT NOT NULL,
	-- Primary index to Thong(Thing in "Thong has Thing")
	PRIMARY KEY CLUSTERED(ThingID),
	FOREIGN KEY (ThingID) REFERENCES Thing (ThingID)
)
GO


