CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE ot (
	-- OT is called Name
	name                                    VARCHAR NOT NULL,
	-- Primary index to OT(Name in "OT is called Name")
	PRIMARY KEY(name)
);


CREATE TABLE vtp (
	-- VTP involves VT that is a kind of DOT that is a kind of OT that is called Name
	vt_name                                 VARCHAR NOT NULL,
	-- VTP involves Name
	name                                    VARCHAR NOT NULL,
	-- Primary index to VTP(VT, Name in "VT has facet called Name")
	PRIMARY KEY(vt_name, name),
	FOREIGN KEY (vt_name) REFERENCES ot (name)
);


CREATE TABLE vtp_restriction (
	-- VTPRestriction involves VT that is a kind of DOT that is a kind of OT that is called Name
	vt_name                                 VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves VT that is a kind of DOT that is a kind of OT that is called Name
	vtp_vt_name                             VARCHAR NOT NULL,
	-- VTPRestriction involves VTP that involves Name
	vtp_name                                VARCHAR NOT NULL,
	-- Primary index to VTPRestriction(VT, VTP in "VT receives VTP")
	PRIMARY KEY(vt_name, vtp_vt_name, vtp_name),
	FOREIGN KEY (vt_name) REFERENCES ot (name),
	FOREIGN KEY (vtp_vt_name, vtp_name) REFERENCES vtp (vt_name, name)
);


