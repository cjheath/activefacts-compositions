CREATE TABLE Magnet (
	-- Magnet has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT IDENTITY NOT NULL,
	-- Primary index to Magnet over PresenceConstraint over (Magnet AutoCounter in "Magnet has Magnet AutoCounter") occurs at most one time
	PRIMARY KEY CLUSTERED(MagnetAutoCounter)
);


CREATE TABLE MagnetPole (
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT NOT NULL,
	-- Is North
	IsNorth                                 BOOLEAN,
	-- Primary index to MagnetPole over PresenceConstraint over (Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north") occurs at most one time
	PRIMARY KEY CLUSTERED(MagnetAutoCounter, IsNorth),
	FOREIGN KEY (MagnetAutoCounter) REFERENCES Magnet (MagnetAutoCounter)
);


