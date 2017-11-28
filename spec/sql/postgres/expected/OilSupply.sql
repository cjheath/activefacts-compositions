CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE acceptable_substitution (
	-- Acceptable Substitution involves Product that has Product Name
	product_name                            VARCHAR NOT NULL,
	-- Acceptable Substitution involves alternate-Product and Product has Product Name
	alternate_product_name                  VARCHAR NOT NULL,
	-- Acceptable Substitution involves Season
	season                                  VARCHAR(6) NOT NULL CHECK(season = 'Autumn' OR season = 'Spring' OR season = 'Summer' OR season = 'Winter'),
	-- Primary index to Acceptable Substitution(Product, Alternate Product, Season in "Product may be substituted by alternate-Product in Season")
	PRIMARY KEY(product_name, alternate_product_name, season)
);


CREATE TABLE "month" (
	-- Month has Month Nr
	month_nr                                INTEGER NOT NULL CHECK((month_nr >= 1 AND month_nr <= 12)),
	-- Month is in Season
	season                                  VARCHAR(6) NOT NULL CHECK(season = 'Autumn' OR season = 'Spring' OR season = 'Summer' OR season = 'Winter'),
	-- Primary index to Month(Month Nr in "Month has Month Nr")
	PRIMARY KEY(month_nr)
);


CREATE TABLE product (
	-- Product has Product Name
	product_name                            VARCHAR NOT NULL,
	-- Primary index to Product(Product Name in "Product has Product Name")
	PRIMARY KEY(product_name)
);


CREATE TABLE production_forecast (
	-- Production Forecast involves Refinery that has Refinery Name
	refinery_name                           VARCHAR(80) NOT NULL,
	-- Production Forecast involves Supply Period that is in Year that has Year Nr
	supply_period_year_nr                   INTEGER NOT NULL,
	-- Production Forecast involves Supply Period that is in Month that has Month Nr
	supply_period_month_nr                  INTEGER NOT NULL CHECK((supply_period_month_nr >= 1 AND supply_period_month_nr <= 12)),
	-- Production Forecast involves Product that has Product Name
	product_name                            VARCHAR NOT NULL,
	-- Production Forecast involves Quantity
	quantity                                INTEGER NOT NULL,
	-- maybe Production Forecast predicts Cost
	cost                                    MONEY NULL,
	-- Primary index to Production Forecast(Refinery, Supply Period, Product in "Refinery in Supply Period will make Product in Quantity")
	PRIMARY KEY(refinery_name, supply_period_year_nr, supply_period_month_nr, product_name),
	FOREIGN KEY (product_name) REFERENCES product (product_name)
);


CREATE TABLE refinery (
	-- Refinery has Refinery Name
	refinery_name                           VARCHAR(80) NOT NULL,
	-- Primary index to Refinery(Refinery Name in "Refinery has Refinery Name")
	PRIMARY KEY(refinery_name)
);


CREATE TABLE region (
	-- Region has Region Name
	region_name                             VARCHAR NOT NULL,
	-- Primary index to Region(Region Name in "Region has Region Name")
	PRIMARY KEY(region_name)
);


CREATE TABLE regional_demand (
	-- Regional Demand involves Region that has Region Name
	region_name                             VARCHAR NOT NULL,
	-- Regional Demand involves Supply Period that is in Year that has Year Nr
	supply_period_year_nr                   INTEGER NOT NULL,
	-- Regional Demand involves Supply Period that is in Month that has Month Nr
	supply_period_month_nr                  INTEGER NOT NULL CHECK((supply_period_month_nr >= 1 AND supply_period_month_nr <= 12)),
	-- Regional Demand involves Product that has Product Name
	product_name                            VARCHAR NOT NULL,
	-- Regional Demand involves Quantity
	quantity                                INTEGER NOT NULL,
	-- Primary index to Regional Demand(Region, Supply Period, Product in "Region in Supply Period will need Product in Quantity")
	PRIMARY KEY(region_name, supply_period_year_nr, supply_period_month_nr, product_name),
	FOREIGN KEY (product_name) REFERENCES product (product_name),
	FOREIGN KEY (region_name) REFERENCES region (region_name)
);


CREATE TABLE supply_period (
	-- Supply Period is in Year that has Year Nr
	year_nr                                 INTEGER NOT NULL,
	-- Supply Period is in Month that has Month Nr
	month_nr                                INTEGER NOT NULL CHECK((month_nr >= 1 AND month_nr <= 12)),
	-- Primary index to Supply Period(Year, Month in "Supply Period is in Year", "Supply Period is in Month")
	PRIMARY KEY(year_nr, month_nr),
	FOREIGN KEY (month_nr) REFERENCES "month" (month_nr)
);


CREATE TABLE transport_route (
	-- Transport Route involves Transport Mode
	transport_mode                          VARCHAR NOT NULL CHECK(transport_mode = 'Rail' OR transport_mode = 'Road' OR transport_mode = 'Sea'),
	-- Transport Route involves Refinery that has Refinery Name
	refinery_name                           VARCHAR(80) NOT NULL,
	-- Transport Route involves Region that has Region Name
	region_name                             VARCHAR NOT NULL,
	-- maybe Transport Route incurs Cost per kl
	cost                                    MONEY NULL,
	-- Primary index to Transport Route(Transport Mode, Refinery, Region in "Transport Mode transportation is available from Refinery to Region")
	PRIMARY KEY(transport_mode, refinery_name, region_name),
	FOREIGN KEY (refinery_name) REFERENCES refinery (refinery_name),
	FOREIGN KEY (region_name) REFERENCES region (region_name)
);


ALTER TABLE acceptable_substitution
	ADD FOREIGN KEY (alternate_product_name) REFERENCES product (product_name);

ALTER TABLE acceptable_substitution
	ADD FOREIGN KEY (product_name) REFERENCES product (product_name);

ALTER TABLE production_forecast
	ADD FOREIGN KEY (refinery_name) REFERENCES refinery (refinery_name);

ALTER TABLE production_forecast
	ADD FOREIGN KEY (supply_period_year_nr, supply_period_month_nr) REFERENCES supply_period (year_nr, month_nr);

ALTER TABLE regional_demand
	ADD FOREIGN KEY (supply_period_year_nr, supply_period_month_nr) REFERENCES supply_period (year_nr, month_nr);
