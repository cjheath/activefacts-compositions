CREATE TABLE OT (
	-- OT ID
	OTID                                    BIGINT IDENTITY NOT NULL,
	-- OT is called Name
	Name                                    varchar NULL,
	-- Primary index to OT
	PRIMARY KEY CLUSTERED(OTID),
	-- Unique index to OT over PresenceConstraint over (Name in "OT is called Name") occurs at most one time
	UNIQUE NONCLUSTERED(Name)
)
GO

CREATE TABLE VTP (
	-- VTP ID
	VTPID                                   BIGINT IDENTITY NOT NULL,
	-- OT ID
	VTOTID                                  BIGINT IDENTITY NOT NULL,
	-- VTP involves Name
	Name                                    varchar NULL,
	-- Primary index to VTP
	PRIMARY KEY CLUSTERED(VTPID),
	-- Unique index to VTP over PresenceConstraint over (VT, Name in "VT has facet called Name") occurs at most one time
	UNIQUE NONCLUSTERED(VTOTID, Name),
	FOREIGN KEY (VTOTID) REFERENCES OT (OTID)
)
GO

CREATE TABLE VTPRestriction (
	-- OT ID
	VTOTID                                  BIGINT IDENTITY NOT NULL,
	-- VTP ID
	VTPID                                   BIGINT IDENTITY NOT NULL,
	-- Primary index to VTPRestriction over PresenceConstraint over (VT, VTP in "VT receives VTP") occurs at most one time
	PRIMARY KEY CLUSTERED(VTOTID, VTPID),
	FOREIGN KEY (VTOTID) REFERENCES OT (OTID),
	FOREIGN KEY (VTPID) REFERENCES VTP (VTPID)
)
GO
