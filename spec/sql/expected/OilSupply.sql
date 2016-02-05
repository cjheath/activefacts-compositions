CREATE TABLE AcceptableSubstitution (
	-- Acceptable Substitution involves Product that has Product Name
	ProductName                             varchar NULL,
	-- Acceptable Substitution involves Product and Product has Product Name
	AlternateProductName                    varchar NULL,
	-- Acceptable Substitution involves Season
	Season                                  varchar(6) NULL CHECK(Season = 'Autumn' OR Season = 'Spring' OR Season = 'Summer' OR Season = 'Winter'),
	-- Primary index to Acceptable Substitution over PresenceConstraint over (Product, Alternate Product, Season in "Product may be substituted by alternate-Product in Season") occurs at most one time
	PRIMARY KEY CLUSTERED(ProductName, AlternateProductName, Season)
)
GO

CREATE TABLE Month (
	-- Month has Month Nr
	MonthNr                                 int NULL CHECK((MonthNr >= 1 AND MonthNr <= 12)),
	-- Month is in Season
	Season                                  varchar(6) NULL CHECK(Season = 'Autumn' OR Season = 'Spring' OR Season = 'Summer' OR Season = 'Winter'),
	-- Primary index to Month over PresenceConstraint over (Month Nr in "Month has Month Nr") occurs at most one time
	PRIMARY KEY CLUSTERED(MonthNr)
)
GO

CREATE TABLE Product (
	-- Product has Product Name
	ProductName                             varchar NULL,
	-- Primary index to Product over PresenceConstraint over (Product Name in "Product has Product Name") occurs at most one time
	PRIMARY KEY CLUSTERED(ProductName)
)
GO

CREATE TABLE ProductionForecast (
	-- Production Forecast involves Refinery that has Refinery Name
	RefineryName                            varchar(80) NULL,
	-- Production Forecast involves Supply Period that is in Year that has Year Nr
	SupplyPeriodYearNr                      int NULL,
	-- Production Forecast involves Supply Period that is in Month that has Month Nr
	SupplyPeriodMonthNr                     int NULL CHECK((SupplyPeriodMonthNr >= 1 AND SupplyPeriodMonthNr <= 12)),
	-- Production Forecast involves Product that has Product Name
	ProductName                             varchar NULL,
	-- Production Forecast involves Quantity
	Quantity                                int NULL,
	-- maybe Production Forecast predicts Cost
	Cost                                    decimal NOT NULL,
	-- Primary index to Production Forecast over PresenceConstraint over (Refinery, Supply Period, Product in "Refinery in Supply Period will make Product in Quantity") occurs one time
	PRIMARY KEY CLUSTERED(RefineryName, SupplyPeriodYearNr, SupplyPeriodMonthNr, ProductName),
	FOREIGN KEY (ProductName) REFERENCES Product (ProductName)
)
GO

CREATE TABLE Refinery (
	-- Refinery has Refinery Name
	RefineryName                            varchar(80) NULL,
	-- Primary index to Refinery over PresenceConstraint over (Refinery Name in "Refinery has Refinery Name") occurs at most one time
	PRIMARY KEY CLUSTERED(RefineryName)
)
GO

CREATE TABLE Region (
	-- Region has Region Name
	RegionName                              varchar NULL,
	-- Primary index to Region over PresenceConstraint over (Region Name in "Region has Region Name") occurs at most one time
	PRIMARY KEY CLUSTERED(RegionName)
)
GO

CREATE TABLE RegionalDemand (
	-- Regional Demand involves Region that has Region Name
	RegionName                              varchar NULL,
	-- Regional Demand involves Supply Period that is in Year that has Year Nr
	SupplyPeriodYearNr                      int NULL,
	-- Regional Demand involves Supply Period that is in Month that has Month Nr
	SupplyPeriodMonthNr                     int NULL CHECK((SupplyPeriodMonthNr >= 1 AND SupplyPeriodMonthNr <= 12)),
	-- Regional Demand involves Product that has Product Name
	ProductName                             varchar NULL,
	-- Regional Demand involves Quantity
	Quantity                                int NULL,
	-- Primary index to Regional Demand over PresenceConstraint over (Region, Supply Period, Product in "Region in Supply Period will need Product in Quantity") occurs one time
	PRIMARY KEY CLUSTERED(RegionName, SupplyPeriodYearNr, SupplyPeriodMonthNr, ProductName),
	FOREIGN KEY (ProductName) REFERENCES Product (ProductName),
	FOREIGN KEY (RegionName) REFERENCES Region (RegionName)
)
GO

CREATE TABLE SupplyPeriod (
	-- Supply Period is in Year that has Year Nr
	YearNr                                  int NULL,
	-- Supply Period is in Month that has Month Nr
	MonthNr                                 int NULL CHECK((MonthNr >= 1 AND MonthNr <= 12)),
	-- Primary index to Supply Period over PresenceConstraint over (Year, Month in "Supply Period is in Year", "Supply Period is in Month") occurs at most one time
	PRIMARY KEY CLUSTERED(YearNr, MonthNr),
	FOREIGN KEY (MonthNr) REFERENCES Month (MonthNr)
)
GO

CREATE TABLE TransportRoute (
	-- Transport Route involves Transport Method
	TransportMethod                         varchar NULL CHECK(TransportMethod = 'Rail' OR TransportMethod = 'Road' OR TransportMethod = 'Sea'),
	-- Transport Route involves Refinery that has Refinery Name
	RefineryName                            varchar(80) NULL,
	-- Transport Route involves Region that has Region Name
	RegionName                              varchar NULL,
	-- maybe Transport Route incurs Cost per kl
	Cost                                    decimal NOT NULL,
	-- Primary index to Transport Route over PresenceConstraint over (Transport Method, Refinery, Region in "Transport Method transportation is available from Refinery to Region") occurs at most one time
	PRIMARY KEY CLUSTERED(TransportMethod, RefineryName, RegionName),
	FOREIGN KEY (RefineryName) REFERENCES Refinery (RefineryName),
	FOREIGN KEY (RegionName) REFERENCES Region (RegionName)
)
GO

ALTER TABLE Product
	ADD FOREIGN KEY (AlternateProductName) REFERENCES Product (ProductName)
GO

ALTER TABLE Product
	ADD FOREIGN KEY (ProductName) REFERENCES Product (ProductName)
GO

ALTER TABLE Refinery
	ADD FOREIGN KEY (RefineryName) REFERENCES Refinery (RefineryName)
GO

ALTER TABLE SupplyPeriod
	ADD FOREIGN KEY (SupplyPeriodYearNr, SupplyPeriodMonthNr) REFERENCES SupplyPeriod (YearNr, MonthNr)
GO

ALTER TABLE SupplyPeriod
	ADD FOREIGN KEY (SupplyPeriodYearNr, SupplyPeriodMonthNr) REFERENCES SupplyPeriod (YearNr, MonthNr)
GO
