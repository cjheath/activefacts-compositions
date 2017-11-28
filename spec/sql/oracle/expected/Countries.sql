CREATE TABLE COUNTRY (
	-- Country has Country Code
	COUNTRY_CODE                            VARCHAR(3) NOT NULL,
	-- Primary index to Country(Country Code in "Country has Country Code")
	PRIMARY KEY(COUNTRY_CODE, COUNTRY_CODE)
);


CREATE TABLE COUNTRY_CODE (
	-- Country Code Value
	COUNTRY_CODE_VALUE                      VARCHAR(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY(COUNTRY_CODE_VALUE)
);


ALTER TABLE COUNTRY
	ADD FOREIGN KEY (COUNTRY_CODE) REFERENCES COUNTRY_CODE (COUNTRY_CODE_VALUE);
