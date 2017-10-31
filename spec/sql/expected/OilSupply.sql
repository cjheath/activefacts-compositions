CREATE TABLE AcceptableSubstitution (
	-- Acceptable Substitution involves Product that has Product Name
	ProductName                             VARCHAR NOT NULL,
	-- Acceptable Substitution involves alternate-Product and Product has Product Name
	AlternateProductName                    VARCHAR NOT NULL,
	-- Acceptable Substitution involves Season
	Season                                  VARCHAR(6) NOT NULL CHECK(Season = 'Autumn' OR Season = 'Spring' OR Season = 'Summer' OR Season = 'Winter'),
	-- Primary index to Acceptable Substitution over PresenceConstraint over (Product, Alternate Product, Season in "Product may be substituted by alternate-Product in Season") occurs at most one time
	PRIMARY KEY(ProductName, AlternateProductName, Season)
);


CREATE TABLE "Month" (
	-- Month has Month Nr
	MonthNr                                 INTEGER NOT NULL CHECK((MonthNr >= 1 AND MonthNr <= 12)),
	-- Month is in Season
	Season                                  VARCHAR(6) NOT NULL CHECK(Season = 'Autumn' OR Season = 'Spring' OR Season = 'Summer' OR Season = 'Winter'),
	-- Primary index to Month over PresenceConstraint over (Month Nr in "Month has Month Nr") occurs at most one time
	PRIMARY KEY(MonthNr)
);


CREATE TABLE Product (
	-- Product has Product Name
	ProductName                             VARCHAR NOT NULL,
	-- Primary index to Product over PresenceConstraint over (Product Name in "Product has Product Name") occurs at most one time
	PRIMARY KEY(ProductName)
);


CREATE TABLE ProductionForecast (
	-- Production Forecast involves Refinery that has Refinery Name
	RefineryName                            VARCHAR(80) NOT NULL,
	-- Production Forecast involves Supply Period that is in Year that has Year Nr
	SupplyPeriodYearNr                      INTEGER NOT NULL,
	-- Production Forecast involves Supply Period that is in Month that has Month Nr
	SupplyPeriodMonthNr                     INTEGER NOT NULL CHECK((SupplyPeriodMonthNr >= 1 AND SupplyPeriodMonthNr <= 12)),
	-- Production Forecast involves Product that has Product Name
	ProductName                             VARCHAR NOT NULL,
	-- Production Forecast involves Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Production Forecast predicts Cost
	Cost                                    DECIMAL NULL,
	-- Primary index to Production Forecast over PresenceConstraint over (Refinery, Supply Period, Product in "Refinery in Supply Period will make Product in Quantity") occurs one time
	PRIMARY KEY(RefineryName, SupplyPeriodYearNr, SupplyPeriodMonthNr, ProductName),
	FOREIGN KEY (ProductName) REFERENCES Product (ProductName)
);


CREATE TABLE Refinery (
	-- Refinery has Refinery Name
	RefineryName                            VARCHAR(80) NOT NULL,
	-- Primary index to Refinery over PresenceConstraint over (Refinery Name in "Refinery has Refinery Name") occurs at most one time
	PRIMARY KEY(RefineryName)
);


CREATE TABLE Region (
	-- Region has Region Name
	RegionName                              VARCHAR NOT NULL,
	-- Primary index to Region over PresenceConstraint over (Region Name in "Region has Region Name") occurs at most one time
	PRIMARY KEY(RegionName)
);


CREATE TABLE RegionalDemand (
	-- Regional Demand involves Region that has Region Name
	RegionName                              VARCHAR NOT NULL,
	-- Regional Demand involves Supply Period that is in Year that has Year Nr
	SupplyPeriodYearNr                      INTEGER NOT NULL,
	-- Regional Demand involves Supply Period that is in Month that has Month Nr
	SupplyPeriodMonthNr                     INTEGER NOT NULL CHECK((SupplyPeriodMonthNr >= 1 AND SupplyPeriodMonthNr <= 12)),
	-- Regional Demand involves Product that has Product Name
	ProductName                             VARCHAR NOT NULL,
	-- Regional Demand involves Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Regional Demand over PresenceConstraint over (Region, Supply Period, Product in "Region in Supply Period will need Product in Quantity") occurs one time
	PRIMARY KEY(RegionName, SupplyPeriodYearNr, SupplyPeriodMonthNr, ProductName),
	FOREIGN KEY (ProductName) REFERENCES Product (ProductName),
	FOREIGN KEY (RegionName) REFERENCES Region (RegionName)
);


CREATE TABLE SupplyPeriod (
	-- Supply Period is in Year that has Year Nr
	YearNr                                  INTEGER NOT NULL,
	-- Supply Period is in Month that has Month Nr
	MonthNr                                 INTEGER NOT NULL CHECK((MonthNr >= 1 AND MonthNr <= 12)),
	-- Primary index to Supply Period over PresenceConstraint over (Year, Month in "Supply Period is in Year", "Supply Period is in Month") occurs at most one time
	PRIMARY KEY(YearNr, MonthNr),
	FOREIGN KEY (MonthNr) REFERENCES "Month" (MonthNr)
);


CREATE TABLE TransportRoute (
	-- Transport Route involves Transport Mode
	TransportMode                           VARCHAR NOT NULL CHECK(TransportMode = 'Rail' OR TransportMode = 'Road' OR TransportMode = 'Sea'),
	-- Transport Route involves Refinery that has Refinery Name
	RefineryName                            VARCHAR(80) NOT NULL,
	-- Transport Route involves Region that has Region Name
	RegionName                              VARCHAR NOT NULL,
	-- maybe Transport Route incurs Cost per kl
	Cost                                    DECIMAL NULL,
	-- Primary index to Transport Route over PresenceConstraint over (Transport Mode, Refinery, Region in "Transport Mode transportation is available from Refinery to Region") occurs at most one time
	PRIMARY KEY(TransportMode, RefineryName, RegionName),
	FOREIGN KEY (RefineryName) REFERENCES Refinery (RefineryName),
	FOREIGN KEY (RegionName) REFERENCES Region (RegionName)
);


ALTER TABLE AcceptableSubstitution
	ADD FOREIGN KEY (AlternateProductName) REFERENCES Product (ProductName);


ALTER TABLE AcceptableSubstitution
	ADD FOREIGN KEY (ProductName) REFERENCES Product (ProductName);


ALTER TABLE ProductionForecast
	ADD FOREIGN KEY (RefineryName) REFERENCES Refinery (RefineryName);


ALTER TABLE ProductionForecast
	ADD FOREIGN KEY (SupplyPeriodYearNr, SupplyPeriodMonthNr) REFERENCES SupplyPeriod (YearNr, MonthNr);


ALTER TABLE RegionalDemand
	ADD FOREIGN KEY (SupplyPeriodYearNr, SupplyPeriodMonthNr) REFERENCES SupplyPeriod (YearNr, MonthNr);

