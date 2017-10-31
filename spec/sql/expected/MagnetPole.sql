CREATE TABLE Magnet (
	-- Magnet has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Magnet over PresenceConstraint over (Magnet AutoCounter in "Magnet has Magnet AutoCounter") occurs at most one time
	PRIMARY KEY(MagnetAutoCounter)
);


CREATE TABLE MagnetPole (
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT NOT NULL,
	-- MagnetPole Is North
	IsNorth                                 BOOLEAN,
	-- Primary index to MagnetPole over PresenceConstraint over (Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north") occurs at most one time
	PRIMARY KEY(MagnetAutoCounter, IsNorth),
	FOREIGN KEY (MagnetAutoCounter) REFERENCES Magnet (MagnetAutoCounter)
);


