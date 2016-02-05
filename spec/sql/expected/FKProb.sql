CREATE TABLE OT (
	-- OT is called Name
	Name                                    varchar NULL,
	-- Primary index to OT over PresenceConstraint over (Name in "OT is called Name") occurs at most one time
	PRIMARY KEY CLUSTERED(Name)
)
GO

CREATE TABLE VTP (
	-- VTP involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTName                                  varchar NULL,
	-- VTP involves Name
	Name                                    varchar NULL,
	-- Primary index to VTP over PresenceConstraint over (VT, Name in "VT has facet called Name") occurs at most one time
	PRIMARY KEY CLUSTERED(VTName, Name),
	FOREIGN KEY (VTName) REFERENCES OT (Name)
)
GO

CREATE TABLE VTPRestriction (
	-- VTPRestriction involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTName                                  varchar NULL,
	-- VTPRestriction involves VTP that involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTPVTName                               varchar NULL,
	-- VTPRestriction involves VTP that involves Name
	VTPName                                 varchar NULL,
	-- Primary index to VTPRestriction over PresenceConstraint over (VT, VTP in "VT receives VTP") occurs at most one time
	PRIMARY KEY CLUSTERED(VTName, VTPVTName, VTPName),
	FOREIGN KEY (VTName) REFERENCES OT (Name),
	FOREIGN KEY (VTPVTName, VTPName) REFERENCES VTP (VTName, Name)
)
GO

