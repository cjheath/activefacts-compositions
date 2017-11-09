CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE asset (
	-- Asset has Asset ID
	asset_id                                BIGSERIAL NOT NULL,
	-- Primary index to Asset over PresenceConstraint over (Asset ID in "Asset has Asset ID") occurs at most one time
	PRIMARY KEY(asset_id)
);


CREATE TABLE claim (
	-- Claim has Claim ID
	claim_id                                BIGSERIAL NOT NULL,
	-- Claim has p_sequence
	p_sequence                              SMALLINT NOT NULL CHECK((p_sequence >= 1 AND p_sequence <= 999)),
	-- Claim is on Policy that was issued in p_year and Year has Year Nr
	policy_p_year_nr                        INTEGER NOT NULL,
	-- Claim is on Policy that is for product having p_product and Product has Product Code
	policy_p_product_code                   SMALLINT NOT NULL CHECK((policy_p_product_code >= 1 AND policy_p_product_code <= 99)),
	-- Claim is on Policy that issued in state having p_state and State has State Code
	policy_p_state_code                     SMALLINT NOT NULL CHECK((policy_p_state_code >= 0 AND policy_p_state_code <= 9)),
	-- Claim is on Policy that has p_serial
	policy_p_serial                         INTEGER NOT NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is at Street
	incident_address_street                 VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is in City
	incident_address_city                   VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in Postcode
	incident_address_postcode               VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in State that has State Code
	incident_address_state_code             SMALLINT NULL,
	-- maybe Claim concerns Incident that relates to loss on Date Time
	incident_date_time                      DATETIME NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was to officer-Name
	incident_officer_name                   VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe has police-Report Nr
	incident_police_report_nr               INTEGER NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was on report-Date Time
	incident_report_date_time               DATETIME NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was by reporter-Name
	incident_reporter_name                  VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was at station-Name
	incident_station_name                   VARCHAR(256) NULL,
	-- maybe Lodgement involves Claim and Lodgement involves Person that is a kind of Party that has Party ID
	lodgement_person_id                     BIGINT NULL,
	-- maybe Lodgement involves Claim and maybe Lodgement was made at Date Time
	lodgement_date_time                     DATETIME NULL,
	-- Primary index to Claim over PresenceConstraint over (Claim ID in "Claim has Claim ID") occurs at most one time
	PRIMARY KEY(claim_id),
	-- Unique index to Claim over PresenceConstraint over (Policy, p_sequence in "Claim is on Policy", "Claim has Claim Sequence") occurs at most one time
	UNIQUE(p_sequence, policy_p_year_nr, policy_p_product_code, policy_p_state_code, policy_p_serial)
);


CREATE TABLE contractor_appointment (
	-- Contractor Appointment involves Claim that has Claim ID
	claim_id                                BIGINT NOT NULL,
	-- Contractor Appointment involves Contractor that is a kind of Company that is a kind of Party that has Party ID
	contractor_id                           BIGINT NOT NULL,
	-- Primary index to Contractor Appointment over PresenceConstraint over (Claim, Contractor in "Claim involves Contractor") occurs at most one time
	PRIMARY KEY(claim_id, contractor_id),
	FOREIGN KEY (claim_id) REFERENCES claim (claim_id)
);


CREATE TABLE cover (
	-- Cover involves Policy that was issued in p_year and Year has Year Nr
	policy_p_year_nr                        INTEGER NOT NULL,
	-- Cover involves Policy that is for product having p_product and Product has Product Code
	policy_p_product_code                   SMALLINT NOT NULL CHECK((policy_p_product_code >= 1 AND policy_p_product_code <= 99)),
	-- Cover involves Policy that issued in state having p_state and State has State Code
	policy_p_state_code                     SMALLINT NOT NULL CHECK((policy_p_state_code >= 0 AND policy_p_state_code <= 9)),
	-- Cover involves Policy that has p_serial
	policy_p_serial                         INTEGER NOT NULL,
	-- Cover involves Cover Type that has Cover Type Code
	cover_type_code                         VARCHAR NOT NULL,
	-- Cover involves Asset that has Asset ID
	asset_id                                BIGINT NOT NULL,
	-- Primary index to Cover over PresenceConstraint over (Policy, Cover Type, Asset in "Policy provides Cover Type over Asset") occurs at most one time
	PRIMARY KEY(policy_p_year_nr, policy_p_product_code, policy_p_state_code, policy_p_serial, cover_type_code, asset_id),
	FOREIGN KEY (asset_id) REFERENCES asset (asset_id)
);


CREATE TABLE cover_type (
	-- Cover Type has Cover Type Code
	cover_type_code                         VARCHAR NOT NULL,
	-- Cover Type has Cover Type Name
	cover_type_name                         VARCHAR NOT NULL,
	-- Primary index to Cover Type over PresenceConstraint over (Cover Type Code in "Cover Type has Cover Type Code") occurs at most one time
	PRIMARY KEY(cover_type_code),
	-- Unique index to Cover Type over PresenceConstraint over (Cover Type Name in "Cover Type has Cover Type Name") occurs at most one time
	UNIQUE(cover_type_name)
);


CREATE TABLE cover_wording (
	-- Cover Wording involves Cover Type that has Cover Type Code
	cover_type_code                         VARCHAR NOT NULL,
	-- Cover Wording involves Policy Wording that has Policy Wording Text
	policy_wording_text                     VARCHAR NOT NULL,
	-- Cover Wording involves start-Date
	start_date                              DATE NOT NULL,
	-- Primary index to Cover Wording over PresenceConstraint over (Cover Type, Policy Wording, Start Date in "Cover Type used Policy Wording from start-Date") occurs at most one time
	PRIMARY KEY(cover_type_code, policy_wording_text, start_date),
	FOREIGN KEY (cover_type_code) REFERENCES cover_type (cover_type_code)
);


CREATE TABLE loss_type (
	-- Loss Type has Loss Type Code
	loss_type_code                          VARCHAR NOT NULL,
	-- Loss Type Involves Driving
	involves_driving                        BOOLEAN,
	-- Loss Type Is Single Vehicle Incident
	is_single_vehicle_incident              BOOLEAN,
	-- maybe Loss Type implies Liability that has Liability Code
	liability_code                          VARCHAR(1) NULL CHECK(liability_code = 'D' OR liability_code = 'L' OR liability_code = 'R' OR liability_code = 'U'),
	-- Primary index to Loss Type over PresenceConstraint over (Loss Type Code in "Loss Type has Loss Type Code") occurs at most one time
	PRIMARY KEY(loss_type_code)
);


CREATE TABLE lost_item (
	-- Lost Item was lost in Incident that is of Claim that has Claim ID
	incident_claim_id                       BIGINT NOT NULL,
	-- Lost Item has Lost Item Nr
	lost_item_nr                            INTEGER NOT NULL,
	-- Lost Item has Description
	description                             VARCHAR(1024) NOT NULL,
	-- maybe Lost Item was purchased on purchase-Date
	purchase_date                           DATE NULL,
	-- maybe Lost Item was purchased at purchase-Place
	purchase_place                          VARCHAR NULL,
	-- maybe Lost Item was purchased for purchase-Price
	purchase_price                          DECIMAL(18, 2) NULL,
	-- Primary index to Lost Item over PresenceConstraint over (Incident, Lost Item Nr in "Lost Item was lost in Incident", "Lost Item has Lost Item Nr") occurs at most one time
	PRIMARY KEY(incident_claim_id, lost_item_nr),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id)
);


CREATE TABLE party (
	-- Party has Party ID
	party_id                                BIGSERIAL NOT NULL,
	-- Party Is A Company
	is_a_company                            BOOLEAN,
	-- maybe Party has postal-Address and Address is at Street
	postal_address_street                   VARCHAR(256) NULL,
	-- maybe Party has postal-Address and Address is in City
	postal_address_city                     VARCHAR NULL,
	-- maybe Party has postal-Address and maybe Address is in Postcode
	postal_address_postcode                 VARCHAR NULL,
	-- maybe Party has postal-Address and maybe Address is in State that has State Code
	postal_address_state_code               SMALLINT NULL,
	-- maybe Party is a Company that has contact-Person and Person is a kind of Party that has Party ID
	company_contact_person_id               BIGINT NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes business-Phone and Phone has Phone Nr
	person_business_phone_nr                VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe prefers contact-Time
	person_contact_time                     TIME NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes Email
	person_email                            VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes home-Phone and Phone has Phone Nr
	person_home_phone_nr                    VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes mobile-Phone and Phone has Phone Nr
	person_mobile_phone_nr                  VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe has preferred-Contact Method
	person_preferred_contact_method         VARCHAR(1) NULL CHECK(person_preferred_contact_method = 'B' OR person_preferred_contact_method = 'H' OR person_preferred_contact_method = 'M'),
	-- maybe Party is a Person that has family-Name
	person_family_name                      VARCHAR(256) NULL,
	-- maybe Party is a Person that has given-Name
	person_given_name                       VARCHAR(256) NULL,
	-- maybe Party is a Person that has Title
	person_title                            VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that is at Street
	person_address_street                   VARCHAR(256) NULL,
	-- maybe Party is a Person that maybe lives at Address that is in City
	person_address_city                     VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that maybe is in Postcode
	person_address_postcode                 VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that maybe is in State that has State Code
	person_address_state_code               SMALLINT NULL,
	-- maybe Party is a Person that maybe has birth-Date
	person_birth_date                       DATE NULL,
	-- maybe Party is a Person that maybe holds License that Is International
	person_is_international                 BOOLEAN,
	-- maybe Party is a Person that maybe holds License that has License Number
	person_license_number                   VARCHAR NULL,
	-- maybe Party is a Person that maybe holds License that is of License Type
	person_license_type                     VARCHAR NULL,
	-- maybe Party is a Person that maybe holds License that maybe was granted in Year that has Year Nr
	person_year_nr                          INTEGER NULL,
	-- maybe Party is a Person that maybe has Occupation
	person_occupation                       VARCHAR NULL,
	-- Primary index to Party over PresenceConstraint over (Party ID in "Party has Party ID") occurs at most one time
	PRIMARY KEY(party_id),
	FOREIGN KEY (company_contact_person_id) REFERENCES party (party_id)
);


CREATE TABLE policy (
	-- Policy was issued in p_year and Year has Year Nr
	p_year_nr                               INTEGER NOT NULL,
	-- Policy is for product having p_product and Product has Product Code
	p_product_code                          SMALLINT NOT NULL,
	-- Policy issued in state having p_state and State has State Code
	p_state_code                            SMALLINT NOT NULL,
	-- Policy has p_serial
	p_serial                                INTEGER NOT NULL CHECK((p_serial >= 1 AND p_serial <= 99999)),
	-- Policy has Application that has Application Nr
	application_nr                          INTEGER NOT NULL,
	-- Policy belongs to Insured that is a kind of Party that has Party ID
	insured_id                              BIGINT NOT NULL,
	-- maybe Policy was sold by Authorised Rep that is a kind of Party that has Party ID
	authorised_rep_id                       BIGINT NULL,
	-- maybe Policy has ITC Claimed
	itc_claimed                             DECIMAL(18, 2) NULL CHECK((itc_claimed >= 0.0 AND itc_claimed <= 100.0)),
	-- Primary index to Policy over PresenceConstraint over (p_year, p_product, p_state, p_serial in "Policy was issued in Year", "Policy is for product having Product", "Policy issued in state having State", "Policy has Policy Serial") occurs at most one time
	PRIMARY KEY(p_year_nr, p_product_code, p_state_code, p_serial),
	FOREIGN KEY (authorised_rep_id) REFERENCES party (party_id),
	FOREIGN KEY (insured_id) REFERENCES party (party_id)
);


CREATE TABLE product (
	-- Product has Product Code
	product_code                            SMALLINT NOT NULL CHECK((product_code >= 1 AND product_code <= 99)),
	-- maybe Product has Alias
	alias                                   VARCHAR(3) NULL,
	-- maybe Product has Description
	description                             VARCHAR(1024) NULL,
	-- Primary index to Product over PresenceConstraint over (Product Code in "Product has Product Code") occurs at most one time
	PRIMARY KEY(product_code)
);

CREATE UNIQUE INDEX productByalias ON product(alias) WHERE alias IS NOT NULL;


CREATE UNIQUE INDEX productBydescription ON product(description) WHERE description IS NOT NULL;


CREATE TABLE property_damage (
	-- maybe Property Damage was damaged in Incident that is of Claim that has Claim ID
	incident_claim_id                       BIGINT NULL,
	-- Property Damage is at Address that is at Street
	address_street                          VARCHAR(256) NOT NULL,
	-- Property Damage is at Address that is in City
	address_city                            VARCHAR NOT NULL,
	-- Property Damage is at Address that maybe is in Postcode
	address_postcode                        VARCHAR NULL,
	-- Property Damage is at Address that maybe is in State that has State Code
	address_state_code                      SMALLINT NULL,
	-- maybe Property Damage belongs to owner-Name
	owner_name                              VARCHAR(256) NULL,
	-- maybe Property Damage owner has contact Phone that has Phone Nr
	phone_nr                                VARCHAR NULL,
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id)
);

CREATE UNIQUE INDEX property_damageByincident_claim_idaddress_streetaddress_549b ON property_damage(incident_claim_id, address_street, address_city, address_postcode, address_state_code) WHERE incident_claim_id IS NOT NULL AND address_postcode IS NOT NULL AND address_state_code IS NOT NULL;


CREATE TABLE state (
	-- State has State Code
	state_code                              SMALLINT NOT NULL CHECK((state_code >= 0 AND state_code <= 9)),
	-- maybe State has State Name
	state_name                              VARCHAR(256) NULL,
	-- Primary index to State over PresenceConstraint over (State Code in "State has State Code") occurs at most one time
	PRIMARY KEY(state_code)
);

CREATE UNIQUE INDEX stateBystate_name ON state(state_name) WHERE state_name IS NOT NULL;


CREATE TABLE third_party (
	-- Third Party involves Person that is a kind of Party that has Party ID
	person_id                               BIGINT NOT NULL,
	-- Third Party involves Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	vehicle_incident_claim_id               BIGINT NOT NULL,
	-- maybe Third Party is insured by Insurer that is a kind of Company that is a kind of Party that has Party ID
	insurer_id                              BIGINT NULL,
	-- maybe Third Party vehicle is of model-Year and Year has Year Nr
	model_year_nr                           INTEGER NULL,
	-- maybe Third Party drove vehicle-Registration and Registration has Registration Nr
	vehicle_registration_nr                 VARCHAR(8) NULL,
	-- maybe Third Party vehicle is of Vehicle Type that is of Make
	vehicle_type_make                       VARCHAR NULL,
	-- maybe Third Party vehicle is of Vehicle Type that is of Model
	vehicle_type_model                      VARCHAR NULL,
	-- maybe Third Party vehicle is of Vehicle Type that maybe has Badge
	vehicle_type_badge                      VARCHAR NULL,
	-- Primary index to Third Party over PresenceConstraint over (Person, Vehicle Incident in "Person was third party in Vehicle Incident") occurs at most one time
	PRIMARY KEY(person_id, vehicle_incident_claim_id),
	FOREIGN KEY (insurer_id) REFERENCES party (party_id),
	FOREIGN KEY (person_id) REFERENCES party (party_id)
);


CREATE TABLE underwriting_demerit (
	-- Underwriting Demerit preceded Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	vehicle_incident_claim_id               BIGINT NOT NULL,
	-- Underwriting Demerit has Underwriting Question that has Underwriting Question ID
	underwriting_question_id                BIGINT NOT NULL,
	-- maybe Underwriting Demerit occurred occurrence-Count times
	occurrence_count                        INTEGER NULL,
	-- Primary index to Underwriting Demerit over PresenceConstraint over (Vehicle Incident, Underwriting Question in "Vehicle Incident occurred despite Underwriting Demerit", "Underwriting Demerit has Underwriting Question") occurs at most one time
	PRIMARY KEY(vehicle_incident_claim_id, underwriting_question_id)
);


CREATE TABLE underwriting_question (
	-- Underwriting Question has Underwriting Question ID
	underwriting_question_id                BIGSERIAL NOT NULL,
	-- Underwriting Question has Text
	text                                    VARCHAR NOT NULL,
	-- Primary index to Underwriting Question over PresenceConstraint over (Underwriting Question ID in "Underwriting Question has Underwriting Question ID") occurs at most one time
	PRIMARY KEY(underwriting_question_id),
	-- Unique index to Underwriting Question over PresenceConstraint over (Text in "Text is of Underwriting Question") occurs at most one time
	UNIQUE(text)
);


CREATE TABLE vehicle (
	-- Vehicle is a kind of Asset that has Asset ID
	asset_id                                BIGINT NOT NULL,
	-- Vehicle has VIN
	vin                                     INTEGER NOT NULL,
	-- Vehicle Has Commercial Registration
	has_commercial_registration             BOOLEAN,
	-- Vehicle is of model-Year and Year has Year Nr
	model_year_nr                           INTEGER NOT NULL,
	-- Vehicle has Registration that has Registration Nr
	registration_nr                         VARCHAR(8) NOT NULL,
	-- Vehicle is of Vehicle Type that is of Make
	vehicle_type_make                       VARCHAR NOT NULL,
	-- Vehicle is of Vehicle Type that is of Model
	vehicle_type_model                      VARCHAR NOT NULL,
	-- Vehicle is of Vehicle Type that maybe has Badge
	vehicle_type_badge                      VARCHAR NULL,
	-- maybe Vehicle is of Colour
	colour                                  VARCHAR NULL,
	-- maybe Vehicle was sold by Dealer that is a kind of Party that has Party ID
	dealer_id                               BIGINT NULL,
	-- maybe Vehicle has Engine Number
	engine_number                           VARCHAR NULL,
	-- maybe Vehicle is subject to finance with Finance Institution that is a kind of Company that is a kind of Party that has Party ID
	finance_institution_id                  BIGINT NULL,
	-- Primary index to Vehicle over PresenceConstraint over (VIN in "Vehicle has VIN") occurs at most one time
	PRIMARY KEY(vin),
	FOREIGN KEY (asset_id) REFERENCES asset (asset_id),
	FOREIGN KEY (dealer_id) REFERENCES party (party_id),
	FOREIGN KEY (finance_institution_id) REFERENCES party (party_id)
);


CREATE TABLE vehicle_incident (
	-- Vehicle Incident is a kind of Incident that is of Claim that has Claim ID
	incident_claim_id                       BIGINT NOT NULL,
	-- Vehicle Incident Occurred While Being Driven
	occurred_while_being_driven             BOOLEAN,
	-- maybe Vehicle Incident has Description
	description                             VARCHAR(1024) NULL,
	-- maybe Driving involves Vehicle Incident and Driving was by Person that is a kind of Party that has Party ID
	driving_person_id                       BIGINT NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving resulted in breath-Test Result
	driving_breath_test_result              VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving Charge involves Driving that Is A Warning
	driving_is_a_warning                    BOOLEAN,
	-- maybe Driving involves Vehicle Incident and maybe Driving Charge involves Driving and Driving Charge involves Charge
	driving_charge                          VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Hospitalization involves Driving and Hospitalization involves Hospital that has Hospital Name
	driving_hospital_name                   VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Hospitalization involves Driving and maybe Hospitalization resulted in blood-Test Result
	driving_blood_test_result               VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving followed Intoxication
	driving_intoxication                    VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving was without owners consent for nonconsent-Reason
	driving_nonconsent_reason               VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving was unlicenced for unlicensed-Reason
	driving_unlicensed_reason               VARCHAR NULL,
	-- maybe Vehicle Incident resulted from Loss Type that has Loss Type Code
	loss_type_code                          VARCHAR NULL,
	-- maybe Vehicle Incident involved previous_damage-Description
	previous_damage_description             VARCHAR(1024) NULL,
	-- maybe Vehicle Incident was caused by Reason
	reason                                  VARCHAR NULL,
	-- maybe Vehicle Incident resulted in vehicle being towed to towed-Location
	towed_location                          VARCHAR NULL,
	-- maybe Vehicle Incident occurred during weather-Description
	weather_description                     VARCHAR(1024) NULL,
	-- Primary index to Vehicle Incident over PresenceConstraint over (Incident in "Vehicle Incident is a kind of Incident") occurs at most one time
	PRIMARY KEY(incident_claim_id),
	FOREIGN KEY (driving_person_id) REFERENCES party (party_id),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id),
	FOREIGN KEY (loss_type_code) REFERENCES loss_type (loss_type_code)
);


CREATE TABLE witness (
	-- Witness saw Incident that is of Claim that has Claim ID
	incident_claim_id                       BIGINT NOT NULL,
	-- Witness is called Name
	name                                    VARCHAR(256) NOT NULL,
	-- maybe Witness lives at Address that is at Street
	address_street                          VARCHAR(256) NULL,
	-- maybe Witness lives at Address that is in City
	address_city                            VARCHAR NULL,
	-- maybe Witness lives at Address that maybe is in Postcode
	address_postcode                        VARCHAR NULL,
	-- maybe Witness lives at Address that maybe is in State that has State Code
	address_state_code                      SMALLINT NULL,
	-- maybe Witness has contact-Phone and Phone has Phone Nr
	contact_phone_nr                        VARCHAR NULL,
	-- Primary index to Witness over PresenceConstraint over (Incident, Name in "Incident was independently witnessed by Witness", "Witness is called Name") occurs at most one time
	PRIMARY KEY(incident_claim_id, name),
	FOREIGN KEY (address_state_code) REFERENCES state (state_code),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id)
);


ALTER TABLE claim
	ADD FOREIGN KEY (incident_address_state_code) REFERENCES state (state_code);


ALTER TABLE claim
	ADD FOREIGN KEY (lodgement_person_id) REFERENCES party (party_id);


ALTER TABLE claim
	ADD FOREIGN KEY (policy_p_year_nr, policy_p_product_code, policy_p_state_code, policy_p_serial) REFERENCES policy (p_year_nr, p_product_code, p_state_code, p_serial);


ALTER TABLE contractor_appointment
	ADD FOREIGN KEY (contractor_id) REFERENCES party (party_id);


ALTER TABLE cover
	ADD FOREIGN KEY (cover_type_code) REFERENCES cover_type (cover_type_code);


ALTER TABLE cover
	ADD FOREIGN KEY (policy_p_year_nr, policy_p_product_code, policy_p_state_code, policy_p_serial) REFERENCES policy (p_year_nr, p_product_code, p_state_code, p_serial);


ALTER TABLE party
	ADD FOREIGN KEY (person_address_state_code) REFERENCES state (state_code);


ALTER TABLE party
	ADD FOREIGN KEY (postal_address_state_code) REFERENCES state (state_code);


ALTER TABLE policy
	ADD FOREIGN KEY (p_product_code) REFERENCES product (product_code);


ALTER TABLE policy
	ADD FOREIGN KEY (p_state_code) REFERENCES state (state_code);


ALTER TABLE property_damage
	ADD FOREIGN KEY (address_state_code) REFERENCES state (state_code);


ALTER TABLE third_party
	ADD FOREIGN KEY (vehicle_incident_claim_id) REFERENCES vehicle_incident (incident_claim_id);


ALTER TABLE underwriting_demerit
	ADD FOREIGN KEY (underwriting_question_id) REFERENCES underwriting_question (underwriting_question_id);


ALTER TABLE underwriting_demerit
	ADD FOREIGN KEY (vehicle_incident_claim_id) REFERENCES vehicle_incident (incident_claim_id);
