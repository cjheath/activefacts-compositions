CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE acceptable_substitution (
	-- Acceptable Substitution surrogate key
	acceptable_substitution_id              BIGSERIAL NOT NULL,
	-- Acceptable Substitution involves Product
	product_id                              BIGINT NOT NULL,
	-- Acceptable Substitution involves alternate-Product
	alternate_product_id                    BIGINT NOT NULL,
	-- Acceptable Substitution involves Season
	season                                  VARCHAR(6) NOT NULL CHECK(season = 'Autumn' OR season = 'Spring' OR season = 'Summer' OR season = 'Winter'),
	-- Primary index to Acceptable Substitution
	PRIMARY KEY(acceptable_substitution_id),
	-- Unique index to Acceptable Substitution over PresenceConstraint over (Product, Alternate Product, Season in "Product may be substituted by alternate-Product in Season") occurs at most one time
	UNIQUE(product_id, alternate_product_id, season)
);


CREATE TABLE "month" (
	-- Month surrogate key
	month_id                                BIGSERIAL NOT NULL,
	-- Month has Month Nr
	month_nr                                INTEGER NOT NULL CHECK((month_nr >= 1 AND month_nr <= 12)),
	-- Month is in Season
	season                                  VARCHAR(6) NOT NULL CHECK(season = 'Autumn' OR season = 'Spring' OR season = 'Summer' OR season = 'Winter'),
	-- Primary index to Month
	PRIMARY KEY(month_id),
	-- Unique index to Month over PresenceConstraint over (Month Nr in "Month has Month Nr") occurs at most one time
	UNIQUE(month_nr)
);


CREATE TABLE product (
	-- Product surrogate key
	product_id                              BIGSERIAL NOT NULL,
	-- Product has Product Name
	product_name                            VARCHAR NOT NULL,
	-- Primary index to Product
	PRIMARY KEY(product_id),
	-- Unique index to Product over PresenceConstraint over (Product Name in "Product has Product Name") occurs at most one time
	UNIQUE(product_name)
);


CREATE TABLE production_forecast (
	-- Production Forecast surrogate key
	production_forecast_id                  BIGSERIAL NOT NULL,
	-- Production Forecast involves Refinery
	refinery_id                             BIGINT NOT NULL,
	-- Production Forecast involves Supply Period
	supply_period_id                        BIGINT NOT NULL,
	-- Production Forecast involves Product
	product_id                              BIGINT NOT NULL,
	-- Production Forecast involves Quantity
	quantity                                INTEGER NOT NULL,
	-- maybe Production Forecast predicts Cost
	cost                                    MONEY NULL,
	-- Primary index to Production Forecast
	PRIMARY KEY(production_forecast_id),
	-- Unique index to Production Forecast over PresenceConstraint over (Refinery, Supply Period, Product in "Refinery in Supply Period will make Product in Quantity") occurs one time
	UNIQUE(refinery_id, supply_period_id, product_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id)
);


CREATE TABLE refinery (
	-- Refinery surrogate key
	refinery_id                             BIGSERIAL NOT NULL,
	-- Refinery has Refinery Name
	refinery_name                           VARCHAR(80) NOT NULL,
	-- Primary index to Refinery
	PRIMARY KEY(refinery_id),
	-- Unique index to Refinery over PresenceConstraint over (Refinery Name in "Refinery has Refinery Name") occurs at most one time
	UNIQUE(refinery_name)
);


CREATE TABLE region (
	-- Region surrogate key
	region_id                               BIGSERIAL NOT NULL,
	-- Region has Region Name
	region_name                             VARCHAR NOT NULL,
	-- Primary index to Region
	PRIMARY KEY(region_id),
	-- Unique index to Region over PresenceConstraint over (Region Name in "Region has Region Name") occurs at most one time
	UNIQUE(region_name)
);


CREATE TABLE regional_demand (
	-- Regional Demand surrogate key
	regional_demand_id                      BIGSERIAL NOT NULL,
	-- Regional Demand involves Region
	region_id                               BIGINT NOT NULL,
	-- Regional Demand involves Supply Period
	supply_period_id                        BIGINT NOT NULL,
	-- Regional Demand involves Product
	product_id                              BIGINT NOT NULL,
	-- Regional Demand involves Quantity
	quantity                                INTEGER NOT NULL,
	-- Primary index to Regional Demand
	PRIMARY KEY(regional_demand_id),
	-- Unique index to Regional Demand over PresenceConstraint over (Region, Supply Period, Product in "Region in Supply Period will need Product in Quantity") occurs one time
	UNIQUE(region_id, supply_period_id, product_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id),
	FOREIGN KEY (region_id) REFERENCES region (region_id)
);


CREATE TABLE supply_period (
	-- Supply Period surrogate key
	supply_period_id                        BIGSERIAL NOT NULL,
	-- Supply Period is in Year that has Year Nr
	year_nr                                 INTEGER NOT NULL,
	-- Supply Period is in Month
	month_id                                BIGINT NOT NULL,
	-- Primary index to Supply Period
	PRIMARY KEY(supply_period_id),
	-- Unique index to Supply Period over PresenceConstraint over (Year, Month in "Supply Period is in Year", "Supply Period is in Month") occurs at most one time
	UNIQUE(year_nr, month_id),
	FOREIGN KEY (month_id) REFERENCES "month" (month_id)
);


CREATE TABLE transport_route (
	-- Transport Route surrogate key
	transport_route_id                      BIGSERIAL NOT NULL,
	-- Transport Route involves Transport Mode
	transport_mode                          VARCHAR NOT NULL CHECK(transport_mode = 'Rail' OR transport_mode = 'Road' OR transport_mode = 'Sea'),
	-- Transport Route involves Refinery
	refinery_id                             BIGINT NOT NULL,
	-- Transport Route involves Region
	region_id                               BIGINT NOT NULL,
	-- maybe Transport Route incurs Cost per kl
	cost                                    MONEY NULL,
	-- Primary index to Transport Route
	PRIMARY KEY(transport_route_id),
	-- Unique index to Transport Route over PresenceConstraint over (Transport Mode, Refinery, Region in "Transport Mode transportation is available from Refinery to Region") occurs at most one time
	UNIQUE(transport_mode, refinery_id, region_id),
	FOREIGN KEY (refinery_id) REFERENCES refinery (refinery_id),
	FOREIGN KEY (region_id) REFERENCES region (region_id)
);


ALTER TABLE acceptable_substitution
	ADD FOREIGN KEY (alternate_product_id) REFERENCES product (product_id);


ALTER TABLE acceptable_substitution
	ADD FOREIGN KEY (product_id) REFERENCES product (product_id);


ALTER TABLE production_forecast
	ADD FOREIGN KEY (refinery_id) REFERENCES refinery (refinery_id);


ALTER TABLE production_forecast
	ADD FOREIGN KEY (supply_period_id) REFERENCES supply_period (supply_period_id);


ALTER TABLE regional_demand
	ADD FOREIGN KEY (supply_period_id) REFERENCES supply_period (supply_period_id);

