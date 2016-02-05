CREATE TABLE Magnet (
	-- Magnet has Magnet AutoCounter
	MagnetAutoCounter                       int NULL IDENTITY,
	-- Primary index to Magnet over PresenceConstraint over (Magnet AutoCounter in "Magnet has Magnet AutoCounter") occurs at most one time
	PRIMARY KEY CLUSTERED(MagnetAutoCounter)
)
GO

CREATE TABLE MagnetPole (
	-- MagnetPole ID
	MagnetPoleID                            BIGINT IDENTITY NOT NULL,
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	MagnetAutoCounter                       int NULL,
	-- Is North
	IsNorth                                 BOOLEAN,
	-- Primary index to MagnetPole
	PRIMARY KEY CLUSTERED(MagnetPoleID),
	-- Unique index to MagnetPole over PresenceConstraint over (Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north") occurs at most one time
	UNIQUE NONCLUSTERED(MagnetAutoCounter, IsNorth),
	FOREIGN KEY (MagnetAutoCounter) REFERENCES Magnet (MagnetAutoCounter)
)
GO

