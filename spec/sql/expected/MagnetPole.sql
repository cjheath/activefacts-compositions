CREATE TABLE Magnet (
	-- Magnet has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Magnet(Magnet AutoCounter in "Magnet has Magnet AutoCounter")
	PRIMARY KEY(MagnetAutoCounter)
);


CREATE TABLE MagnetPole (
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	MagnetAutoCounter                       BIGINT NOT NULL,
	-- MagnetPole Is North
	IsNorth                                 BOOLEAN,
	-- Primary index to MagnetPole(Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north")
	PRIMARY KEY(MagnetAutoCounter, IsNorth),
	FOREIGN KEY (MagnetAutoCounter) REFERENCES Magnet (MagnetAutoCounter)
);


