CREATE TABLE OT (
	-- OT is called Name
	Name                                    VARCHAR NOT NULL,
	-- Primary index to OT(Name in "OT is called Name")
	PRIMARY KEY(Name)
);


CREATE TABLE VTP (
	-- VTP involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTName                                  VARCHAR NOT NULL,
	-- VTP involves Name
	Name                                    VARCHAR NOT NULL,
	-- Primary index to VTP(VT, Name in "VT has facet called Name")
	PRIMARY KEY(VTName, Name),
	FOREIGN KEY (VTName) REFERENCES OT (Name)
);


CREATE TABLE VTPRestriction (
	-- VTPRestriction involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTName                                  VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTPVTName                               VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves Name
	VTPName                                 VARCHAR NOT NULL,
	-- Primary index to VTPRestriction(VT, VTP in "VT receives VTP")
	PRIMARY KEY(VTName, VTPVTName, VTPName),
	FOREIGN KEY (VTName) REFERENCES OT (Name),
	FOREIGN KEY (VTPVTName, VTPName) REFERENCES VTP (VTName, Name)
);


