CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE ot (
	-- OT surrogate key
	ot_id                                   BIGSERIAL NOT NULL,
	-- OT is called Name
	name                                    VARCHAR NOT NULL,
	-- Natural index to OT(Name in "OT is called Name")
	UNIQUE(name),
	-- Primary index to OT
	PRIMARY KEY(ot_id)
);


CREATE TABLE vtp (
	-- VTP surrogate key
	vtp_id                                  BIGSERIAL NOT NULL,
	-- VTP involves VT that is a kind of DOT that is a kind of OT
	vt_ot_id                                BIGINT NOT NULL,
	-- VTP involves Name
	name                                    VARCHAR NOT NULL,
	-- Natural index to VTP(VT, Name in "VT has facet called Name")
	UNIQUE(vt_ot_id, name),
	-- Primary index to VTP
	PRIMARY KEY(vtp_id),
	FOREIGN KEY (vt_ot_id) REFERENCES ot (ot_id)
);


CREATE TABLE vtp_restriction (
	-- VTPRestriction involves VT that is a kind of DOT that is a kind of OT
	vt_ot_id                                BIGINT NOT NULL,
	-- VTPRestriction involves VTP
	vtp_id                                  BIGINT NOT NULL,
	-- Primary index to VTPRestriction(VT, VTP in "VT receives VTP")
	PRIMARY KEY(vt_ot_id, vtp_id),
	FOREIGN KEY (vt_ot_id) REFERENCES ot (ot_id),
	FOREIGN KEY (vtp_id) REFERENCES vtp (vtp_id)
);


