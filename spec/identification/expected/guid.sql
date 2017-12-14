CREATE TABLE Thing (
	-- Thing has Guid
	Guid                                    UNIQUEIDENTIFIER(16) NOT NULL DEFAULT NEWID(),
	-- Primary index to Thing(Guid in "Thing has Guid")
	PRIMARY KEY CLUSTERED(Guid)
)
GO


CREATE TABLE Thong (
	-- Thong has Thing that has Guid
	ThingGuid                               UNIQUEIDENTIFIER(16) NOT NULL,
	-- Primary index to Thong(Thing in "Thong has Thing")
	PRIMARY KEY CLUSTERED(ThingGuid),
	FOREIGN KEY (ThingGuid) REFERENCES Thing (Guid)
)
GO


