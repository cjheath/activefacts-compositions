CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE magnet (
	-- Magnet has Magnet AutoCounter
	magnet_auto_counter                     BIGSERIAL NOT NULL,
	-- Primary index to Magnet over PresenceConstraint over (Magnet AutoCounter in "Magnet has Magnet AutoCounter") occurs at most one time
	PRIMARY KEY(magnet_auto_counter)
);


CREATE TABLE magnet_pole (
	-- MagnetPole surrogate key
	magnet_pole_id                          BIGSERIAL NOT NULL,
	-- MagnetPole belongs to Magnet that has Magnet AutoCounter
	magnet_auto_counter                     BIGINT NOT NULL,
	-- MagnetPole Is North
	is_north                                BOOLEAN,
	-- Primary index to MagnetPole
	PRIMARY KEY(magnet_pole_id),
	-- Unique index to MagnetPole over PresenceConstraint over (Magnet, Is North in "MagnetPole belongs to Magnet", "MagnetPole is north") occurs at most one time
	UNIQUE(magnet_auto_counter, is_north),
	FOREIGN KEY (magnet_auto_counter) REFERENCES magnet (magnet_auto_counter)
);


