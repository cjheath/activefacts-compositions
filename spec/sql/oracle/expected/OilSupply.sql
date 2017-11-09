CREATE TABLE ACCEPTABLE_SUBSTITUTION (
	-- Acceptable Substitution involves Product that has Product Name
	PRODUCT_NAME                            VARCHAR NOT NULL,
	-- Acceptable Substitution involves alternate-Product and Product has Product Name
	ALTERNATE_PRODUCT_NAME                  VARCHAR NOT NULL,
	-- Acceptable Substitution involves Season
	SEASON                                  VARCHAR(6) NOT NULL CHECK(SEASON = 'Autumn' OR SEASON = 'Spring' OR SEASON = 'Summer' OR SEASON = 'Winter'),
	-- Primary index to Acceptable Substitution over PresenceConstraint over (Product, Alternate Product, Season in "Product may be substituted by alternate-Product in Season") occurs at most one time
	PRIMARY KEY(PRODUCT_NAME, ALTERNATE_PRODUCT_NAME, SEASON)
);


CREATE TABLE "MONTH" (
	-- Month has Month Nr
	MONTH_NR                                INTEGER NOT NULL CHECK((MONTH_NR >= 1 AND MONTH_NR <= 12)),
	-- Month is in Season
	SEASON                                  VARCHAR(6) NOT NULL CHECK(SEASON = 'Autumn' OR SEASON = 'Spring' OR SEASON = 'Summer' OR SEASON = 'Winter'),
	-- Primary index to Month over PresenceConstraint over (Month Nr in "Month has Month Nr") occurs at most one time
	PRIMARY KEY(MONTH_NR)
);


CREATE TABLE PRODUCT (
	-- Product has Product Name
	PRODUCT_NAME                            VARCHAR NOT NULL,
	-- Primary index to Product over PresenceConstraint over (Product Name in "Product has Product Name") occurs at most one time
	PRIMARY KEY(PRODUCT_NAME)
);


CREATE TABLE PRODUCTION_FORECAST (
	-- Production Forecast involves Refinery that has Refinery Name
	REFINERY_NAME                           VARCHAR(80) NOT NULL,
	-- Production Forecast involves Supply Period that is in Year that has Year Nr
	SUPPLY_PERIOD_YEAR_NR                   INTEGER NOT NULL,
	-- Production Forecast involves Supply Period that is in Month that has Month Nr
	SUPPLY_PERIOD_MONTH_NR                  INTEGER NOT NULL CHECK((SUPPLY_PERIOD_MONTH_NR >= 1 AND SUPPLY_PERIOD_MONTH_NR <= 12)),
	-- Production Forecast involves Product that has Product Name
	PRODUCT_NAME                            VARCHAR NOT NULL,
	-- Production Forecast involves Quantity
	QUANTITY                                INTEGER NOT NULL,
	-- maybe Production Forecast predicts Cost
	COST                                    MONEY NULL,
	-- Primary index to Production Forecast over PresenceConstraint over (Refinery, Supply Period, Product in "Refinery in Supply Period will make Product in Quantity") occurs one time
	PRIMARY KEY(REFINERY_NAME, SUPPLY_PERIOD_YEAR_NR, SUPPLY_PERIOD_MONTH_NR, PRODUCT_NAME),
	FOREIGN KEY (PRODUCT_NAME) REFERENCES PRODUCT (PRODUCT_NAME)
);


CREATE TABLE REFINERY (
	-- Refinery has Refinery Name
	REFINERY_NAME                           VARCHAR(80) NOT NULL,
	-- Primary index to Refinery over PresenceConstraint over (Refinery Name in "Refinery has Refinery Name") occurs at most one time
	PRIMARY KEY(REFINERY_NAME)
);


CREATE TABLE REGION (
	-- Region has Region Name
	REGION_NAME                             VARCHAR NOT NULL,
	-- Primary index to Region over PresenceConstraint over (Region Name in "Region has Region Name") occurs at most one time
	PRIMARY KEY(REGION_NAME)
);


CREATE TABLE REGIONAL_DEMAND (
	-- Regional Demand involves Region that has Region Name
	REGION_NAME                             VARCHAR NOT NULL,
	-- Regional Demand involves Supply Period that is in Year that has Year Nr
	SUPPLY_PERIOD_YEAR_NR                   INTEGER NOT NULL,
	-- Regional Demand involves Supply Period that is in Month that has Month Nr
	SUPPLY_PERIOD_MONTH_NR                  INTEGER NOT NULL CHECK((SUPPLY_PERIOD_MONTH_NR >= 1 AND SUPPLY_PERIOD_MONTH_NR <= 12)),
	-- Regional Demand involves Product that has Product Name
	PRODUCT_NAME                            VARCHAR NOT NULL,
	-- Regional Demand involves Quantity
	QUANTITY                                INTEGER NOT NULL,
	-- Primary index to Regional Demand over PresenceConstraint over (Region, Supply Period, Product in "Region in Supply Period will need Product in Quantity") occurs one time
	PRIMARY KEY(REGION_NAME, SUPPLY_PERIOD_YEAR_NR, SUPPLY_PERIOD_MONTH_NR, PRODUCT_NAME),
	FOREIGN KEY (PRODUCT_NAME) REFERENCES PRODUCT (PRODUCT_NAME),
	FOREIGN KEY (REGION_NAME) REFERENCES REGION (REGION_NAME)
);


CREATE TABLE SUPPLY_PERIOD (
	-- Supply Period is in Year that has Year Nr
	YEAR_NR                                 INTEGER NOT NULL,
	-- Supply Period is in Month that has Month Nr
	MONTH_NR                                INTEGER NOT NULL CHECK((MONTH_NR >= 1 AND MONTH_NR <= 12)),
	-- Primary index to Supply Period over PresenceConstraint over (Year, Month in "Supply Period is in Year", "Supply Period is in Month") occurs at most one time
	PRIMARY KEY(YEAR_NR, MONTH_NR),
	FOREIGN KEY (MONTH_NR) REFERENCES "MONTH" (MONTH_NR)
);


CREATE TABLE TRANSPORT_ROUTE (
	-- Transport Route involves Transport Mode
	TRANSPORT_MODE                          VARCHAR NOT NULL CHECK(TRANSPORT_MODE = 'Rail' OR TRANSPORT_MODE = 'Road' OR TRANSPORT_MODE = 'Sea'),
	-- Transport Route involves Refinery that has Refinery Name
	REFINERY_NAME                           VARCHAR(80) NOT NULL,
	-- Transport Route involves Region that has Region Name
	REGION_NAME                             VARCHAR NOT NULL,
	-- maybe Transport Route incurs Cost per kl
	COST                                    MONEY NULL,
	-- Primary index to Transport Route over PresenceConstraint over (Transport Mode, Refinery, Region in "Transport Mode transportation is available from Refinery to Region") occurs at most one time
	PRIMARY KEY(TRANSPORT_MODE, REFINERY_NAME, REGION_NAME),
	FOREIGN KEY (REFINERY_NAME) REFERENCES REFINERY (REFINERY_NAME),
	FOREIGN KEY (REGION_NAME) REFERENCES REGION (REGION_NAME)
);


ALTER TABLE ACCEPTABLE_SUBSTITUTION
	ADD FOREIGN KEY (ALTERNATE_PRODUCT_NAME) REFERENCES PRODUCT (PRODUCT_NAME);


ALTER TABLE ACCEPTABLE_SUBSTITUTION
	ADD FOREIGN KEY (PRODUCT_NAME) REFERENCES PRODUCT (PRODUCT_NAME);


ALTER TABLE PRODUCTION_FORECAST
	ADD FOREIGN KEY (REFINERY_NAME) REFERENCES REFINERY (REFINERY_NAME);


ALTER TABLE PRODUCTION_FORECAST
	ADD FOREIGN KEY (SUPPLY_PERIOD_YEAR_NR, SUPPLY_PERIOD_MONTH_NR) REFERENCES SUPPLY_PERIOD (YEAR_NR, MONTH_NR);


ALTER TABLE REGIONAL_DEMAND
	ADD FOREIGN KEY (SUPPLY_PERIOD_YEAR_NR, SUPPLY_PERIOD_MONTH_NR) REFERENCES SUPPLY_PERIOD (YEAR_NR, MONTH_NR);

