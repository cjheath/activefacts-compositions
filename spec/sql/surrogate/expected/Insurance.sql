CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE asset (
	-- Asset has Asset ID
	asset_id                                BIGSERIAL NOT NULL,
	-- Primary index to Asset(Asset ID in "Asset has Asset ID")
	PRIMARY KEY(asset_id)
);


CREATE TABLE claim (
	-- Claim has Claim ID
	claim_id                                BIGSERIAL NOT NULL,
	-- Claim has p_sequence
	p_sequence                              SMALLINT NOT NULL CHECK((p_sequence >= 1 AND p_sequence <= 999)),
	-- Claim is on Policy
	policy_id                               BIGINT NOT NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is at Street
	incident_address_street                 VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is in City
	incident_address_city                   VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in Postcode
	incident_address_postcode               VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in State
	incident_address_state_id               BIGINT NULL,
	-- maybe Claim concerns Incident that relates to loss on Date Time
	incident_date_time                      TIMESTAMP NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was to officer-Name
	incident_officer_name                   VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe has police-Report Nr
	incident_police_report_nr               INTEGER NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was on report-Date Time
	incident_report_date_time               TIMESTAMP NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was by reporter-Name
	incident_reporter_name                  VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was at station-Name
	incident_station_name                   VARCHAR(256) NULL,
	-- maybe Lodgement involves Claim and Lodgement involves Person that is a kind of Party that has Party ID
	lodgement_person_id                     BIGINT NULL,
	-- maybe Lodgement involves Claim and maybe Lodgement was made at Date Time
	lodgement_date_time                     TIMESTAMP NULL,
	-- Primary index to Claim(Claim ID in "Claim has Claim ID")
	PRIMARY KEY(claim_id),
	-- Unique index to Claim(Policy, p_sequence in "Claim is on Policy", "Claim has Claim Sequence")
	UNIQUE(p_sequence, policy_id)
);


CREATE TABLE contractor_appointment (
	-- Contractor Appointment involves Claim that has Claim ID
	claim_id                                BIGINT NOT NULL,
	-- Contractor Appointment involves Contractor that is a kind of Company that is a kind of Party that has Party ID
	contractor_id                           BIGINT NOT NULL,
	-- Primary index to Contractor Appointment(Claim, Contractor in "Claim involves Contractor")
	PRIMARY KEY(claim_id, contractor_id),
	FOREIGN KEY (claim_id) REFERENCES claim (claim_id)
);


CREATE TABLE cover (
	-- Cover involves Policy
	policy_id                               BIGINT NOT NULL,
	-- Cover involves Cover Type
	cover_type_id                           BIGINT NOT NULL,
	-- Cover involves Asset that has Asset ID
	asset_id                                BIGINT NOT NULL,
	-- Primary index to Cover(Policy, Cover Type, Asset in "Policy provides Cover Type over Asset")
	PRIMARY KEY(policy_id, cover_type_id, asset_id),
	FOREIGN KEY (asset_id) REFERENCES asset (asset_id)
);


CREATE TABLE cover_type (
	-- Cover Type surrogate key
	cover_type_id                           BIGSERIAL NOT NULL,
	-- Cover Type has Cover Type Code
	cover_type_code                         VARCHAR NOT NULL,
	-- Cover Type has Cover Type Name
	cover_type_name                         VARCHAR NOT NULL,
	-- Natural index to Cover Type(Cover Type Code in "Cover Type has Cover Type Code")
	UNIQUE(cover_type_code),
	-- Primary index to Cover Type
	PRIMARY KEY(cover_type_id),
	-- Unique index to Cover Type(Cover Type Name in "Cover Type has Cover Type Name")
	UNIQUE(cover_type_name)
);


CREATE TABLE cover_wording (
	-- Cover Wording surrogate key
	cover_wording_id                        BIGSERIAL NOT NULL,
	-- Cover Wording involves Cover Type
	cover_type_id                           BIGINT NOT NULL,
	-- Cover Wording involves Policy Wording that has Policy Wording Text
	policy_wording_text                     VARCHAR NOT NULL,
	-- Cover Wording involves start-Date
	start_date                              DATE NOT NULL,
	-- Natural index to Cover Wording(Cover Type, Policy Wording, Start Date in "Cover Type used Policy Wording from start-Date")
	UNIQUE(cover_type_id, policy_wording_text, start_date),
	-- Primary index to Cover Wording
	PRIMARY KEY(cover_wording_id),
	FOREIGN KEY (cover_type_id) REFERENCES cover_type (cover_type_id)
);


CREATE TABLE loss_type (
	-- Loss Type surrogate key
	loss_type_id                            BIGSERIAL NOT NULL,
	-- Loss Type has Loss Type Code
	loss_type_code                          VARCHAR NOT NULL,
	-- Loss Type Involves Driving
	involves_driving                        BOOLEAN,
	-- Loss Type Is Single Vehicle Incident
	is_single_vehicle_incident              BOOLEAN,
	-- maybe Loss Type implies Liability that has Liability Code
	liability_code                          VARCHAR(1) NULL CHECK(liability_code = 'D' OR liability_code = 'L' OR liability_code = 'R' OR liability_code = 'U'),
	-- Natural index to Loss Type(Loss Type Code in "Loss Type has Loss Type Code")
	UNIQUE(loss_type_code),
	-- Primary index to Loss Type
	PRIMARY KEY(loss_type_id)
);


CREATE TABLE lost_item (
	-- Lost Item surrogate key
	lost_item_id                            BIGSERIAL NOT NULL,
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
	-- Natural index to Lost Item(Incident, Lost Item Nr in "Lost Item was lost in Incident", "Lost Item has Lost Item Nr")
	UNIQUE(incident_claim_id, lost_item_nr),
	-- Primary index to Lost Item
	PRIMARY KEY(lost_item_id),
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
	-- maybe Party has postal-Address and maybe Address is in State
	postal_address_state_id                 BIGINT NULL,
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
	-- maybe Party is a Person that maybe lives at Address that maybe is in State
	person_address_state_id                 BIGINT NULL,
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
	-- Primary index to Party(Party ID in "Party has Party ID")
	PRIMARY KEY(party_id),
	FOREIGN KEY (company_contact_person_id) REFERENCES party (party_id)
);


CREATE TABLE policy (
	-- Policy surrogate key
	policy_id                               BIGSERIAL NOT NULL,
	-- Policy was issued in p_year and Year has Year Nr
	p_year_nr                               INTEGER NOT NULL,
	-- Policy is for product having p_product
	p_product_id                            BIGINT NOT NULL,
	-- Policy issued in state having p_state
	p_state_id                              BIGINT NOT NULL,
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
	-- Natural index to Policy(p_year, p_product, p_state, p_serial in "Policy was issued in Year", "Policy is for product having Product", "Policy issued in state having State", "Policy has Policy Serial")
	UNIQUE(p_year_nr, p_product_id, p_state_id, p_serial),
	-- Primary index to Policy
	PRIMARY KEY(policy_id),
	FOREIGN KEY (authorised_rep_id) REFERENCES party (party_id),
	FOREIGN KEY (insured_id) REFERENCES party (party_id)
);


CREATE TABLE product (
	-- Product surrogate key
	product_id                              BIGSERIAL NOT NULL,
	-- Product has Product Code
	product_code                            SMALLINT NOT NULL CHECK((product_code >= 1 AND product_code <= 99)),
	-- maybe Product has Alias
	alias                                   VARCHAR(3) NULL,
	-- maybe Product has Description
	description                             VARCHAR(1024) NULL,
	-- Natural index to Product(Product Code in "Product has Product Code")
	UNIQUE(product_code),
	-- Primary index to Product
	PRIMARY KEY(product_id),
	-- Unique index to Product(Alias in "Alias is of Product")
	UNIQUE(alias),
	-- Unique index to Product(Description in "Description is of Product")
	UNIQUE(description)
);


CREATE TABLE property_damage (
	-- Property Damage surrogate key
	property_damage_id                      BIGSERIAL NOT NULL,
	-- maybe Property Damage was damaged in Incident that is of Claim that has Claim ID
	incident_claim_id                       BIGINT NULL,
	-- Property Damage is at Address that is at Street
	address_street                          VARCHAR(256) NOT NULL,
	-- Property Damage is at Address that is in City
	address_city                            VARCHAR NOT NULL,
	-- Property Damage is at Address that maybe is in Postcode
	address_postcode                        VARCHAR NULL,
	-- Property Damage is at Address that maybe is in State
	address_state_id                        BIGINT NULL,
	-- maybe Property Damage belongs to owner-Name
	owner_name                              VARCHAR(256) NULL,
	-- maybe Property Damage owner has contact Phone that has Phone Nr
	phone_nr                                VARCHAR NULL,
	-- Natural index to Property Damage(Incident, Address in "Incident caused Property Damage", "Property Damage is at Address")
	UNIQUE(incident_claim_id, address_street, address_city, address_postcode, address_state_id),
	-- Primary index to Property Damage
	PRIMARY KEY(property_damage_id),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id)
);


CREATE TABLE state (
	-- State surrogate key
	state_id                                BIGSERIAL NOT NULL,
	-- State has State Code
	state_code                              SMALLINT NOT NULL CHECK((state_code >= 0 AND state_code <= 9)),
	-- maybe State has State Name
	state_name                              VARCHAR(256) NULL,
	-- Natural index to State(State Code in "State has State Code")
	UNIQUE(state_code),
	-- Primary index to State
	PRIMARY KEY(state_id),
	-- Unique index to State(State Name in "State Name is of State")
	UNIQUE(state_name)
);


CREATE TABLE third_party (
	-- Third Party surrogate key
	third_party_id                          BIGSERIAL NOT NULL,
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
	-- Natural index to Third Party(Person, Vehicle Incident in "Person was third party in Vehicle Incident")
	UNIQUE(person_id, vehicle_incident_claim_id),
	-- Primary index to Third Party
	PRIMARY KEY(third_party_id),
	FOREIGN KEY (insurer_id) REFERENCES party (party_id),
	FOREIGN KEY (person_id) REFERENCES party (party_id)
);


CREATE TABLE underwriting_demerit (
	-- Underwriting Demerit surrogate key
	underwriting_demerit_id                 BIGSERIAL NOT NULL,
	-- Underwriting Demerit preceded Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	vehicle_incident_claim_id               BIGINT NOT NULL,
	-- Underwriting Demerit has Underwriting Question that has Underwriting Question ID
	underwriting_question_id                BIGINT NOT NULL,
	-- maybe Underwriting Demerit occurred occurrence-Count times
	occurrence_count                        INTEGER NULL,
	-- Natural index to Underwriting Demerit(Vehicle Incident, Underwriting Question in "Vehicle Incident occurred despite Underwriting Demerit", "Underwriting Demerit has Underwriting Question")
	UNIQUE(vehicle_incident_claim_id, underwriting_question_id),
	-- Primary index to Underwriting Demerit
	PRIMARY KEY(underwriting_demerit_id)
);


CREATE TABLE underwriting_question (
	-- Underwriting Question has Underwriting Question ID
	underwriting_question_id                BIGSERIAL NOT NULL,
	-- Underwriting Question has Text
	text                                    VARCHAR NOT NULL,
	-- Primary index to Underwriting Question(Underwriting Question ID in "Underwriting Question has Underwriting Question ID")
	PRIMARY KEY(underwriting_question_id),
	-- Unique index to Underwriting Question(Text in "Text is of Underwriting Question")
	UNIQUE(text)
);


CREATE TABLE vehicle (
	-- Vehicle surrogate key
	vehicle_id                              BIGSERIAL NOT NULL,
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
	-- Natural index to Vehicle(VIN in "Vehicle has VIN")
	UNIQUE(vin),
	-- Primary index to Vehicle
	PRIMARY KEY(vehicle_id),
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
	-- maybe Vehicle Incident resulted from Loss Type
	loss_type_id                            BIGINT NULL,
	-- maybe Vehicle Incident involved previous_damage-Description
	previous_damage_description             VARCHAR(1024) NULL,
	-- maybe Vehicle Incident was caused by Reason
	reason                                  VARCHAR NULL,
	-- maybe Vehicle Incident resulted in vehicle being towed to towed-Location
	towed_location                          VARCHAR NULL,
	-- maybe Vehicle Incident occurred during weather-Description
	weather_description                     VARCHAR(1024) NULL,
	-- Primary index to Vehicle Incident(Incident in "Vehicle Incident is a kind of Incident")
	PRIMARY KEY(incident_claim_id),
	FOREIGN KEY (driving_person_id) REFERENCES party (party_id),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id),
	FOREIGN KEY (loss_type_id) REFERENCES loss_type (loss_type_id)
);


CREATE TABLE witness (
	-- Witness surrogate key
	witness_id                              BIGSERIAL NOT NULL,
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
	-- maybe Witness lives at Address that maybe is in State
	address_state_id                        BIGINT NULL,
	-- maybe Witness has contact-Phone and Phone has Phone Nr
	contact_phone_nr                        VARCHAR NULL,
	-- Natural index to Witness(Incident, Name in "Incident was independently witnessed by Witness", "Witness is called Name")
	UNIQUE(incident_claim_id, name),
	-- Primary index to Witness
	PRIMARY KEY(witness_id),
	FOREIGN KEY (address_state_id) REFERENCES state (state_id),
	FOREIGN KEY (incident_claim_id) REFERENCES claim (claim_id)
);


ALTER TABLE claim
	ADD FOREIGN KEY (incident_address_state_id) REFERENCES state (state_id);

ALTER TABLE claim
	ADD FOREIGN KEY (lodgement_person_id) REFERENCES party (party_id);

ALTER TABLE claim
	ADD FOREIGN KEY (policy_id) REFERENCES policy (policy_id);

ALTER TABLE contractor_appointment
	ADD FOREIGN KEY (contractor_id) REFERENCES party (party_id);

ALTER TABLE cover
	ADD FOREIGN KEY (cover_type_id) REFERENCES cover_type (cover_type_id);

ALTER TABLE cover
	ADD FOREIGN KEY (policy_id) REFERENCES policy (policy_id);

ALTER TABLE party
	ADD FOREIGN KEY (person_address_state_id) REFERENCES state (state_id);

ALTER TABLE party
	ADD FOREIGN KEY (postal_address_state_id) REFERENCES state (state_id);

ALTER TABLE policy
	ADD FOREIGN KEY (p_product_id) REFERENCES product (product_id);

ALTER TABLE policy
	ADD FOREIGN KEY (p_state_id) REFERENCES state (state_id);

ALTER TABLE property_damage
	ADD FOREIGN KEY (address_state_id) REFERENCES state (state_id);

ALTER TABLE third_party
	ADD FOREIGN KEY (vehicle_incident_claim_id) REFERENCES vehicle_incident (incident_claim_id);

ALTER TABLE underwriting_demerit
	ADD FOREIGN KEY (underwriting_question_id) REFERENCES underwriting_question (underwriting_question_id);

ALTER TABLE underwriting_demerit
	ADD FOREIGN KEY (vehicle_incident_claim_id) REFERENCES vehicle_incident (incident_claim_id);
