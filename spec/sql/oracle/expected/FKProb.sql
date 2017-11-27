CREATE TABLE OT (
	-- OT is called Name
	NAME                                    VARCHAR NOT NULL,
	-- Primary index to OT(Name in "OT is called Name")
	PRIMARY KEY(NAME)
);


CREATE TABLE VTP (
	-- VTP involves VT that is a kind of DOT that is a kind of OT that is called Name
	VT_NAME                                 VARCHAR NOT NULL,
	-- VTP involves Name
	NAME                                    VARCHAR NOT NULL,
	-- Primary index to VTP(VT, Name in "VT has facet called Name")
	PRIMARY KEY(VT_NAME, NAME),
	FOREIGN KEY (VT_NAME) REFERENCES OT (NAME)
);


CREATE TABLE VTP_RESTRICTION (
	-- VTPRestriction involves VT that is a kind of DOT that is a kind of OT that is called Name
	VT_NAME                                 VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves VT that is a kind of DOT that is a kind of OT that is called Name
	VTP_VT_NAME                             VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves Name
	VTP_NAME                                VARCHAR NOT NULL,
	-- Primary index to VTPRestriction(VT, VTP in "VT receives VTP")
	PRIMARY KEY(VT_NAME, VTP_VT_NAME, VTP_NAME),
	FOREIGN KEY (VTP_VT_NAME, VTP_NAME) REFERENCES VTP (VT_NAME, NAME),
	FOREIGN KEY (VT_NAME) REFERENCES OT (NAME)
);


