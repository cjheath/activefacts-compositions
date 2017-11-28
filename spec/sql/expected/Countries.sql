CREATE TABLE Country (
	-- Country has Country Code
	CountryCode                             CHARACTER(3) NOT NULL,
	-- Primary index to Country(Country Code in "Country has Country Code")
	PRIMARY KEY(CountryCode, CountryCode)
);


CREATE TABLE CountryCode (
	-- Country Code Value
	CountryCodeValue                        CHARACTER(3) NOT NULL,
	-- Primary index to Country Code
	PRIMARY KEY(CountryCodeValue)
);


ALTER TABLE Country
	ADD FOREIGN KEY (CountryCode) REFERENCES CountryCode (CountryCodeValue);
