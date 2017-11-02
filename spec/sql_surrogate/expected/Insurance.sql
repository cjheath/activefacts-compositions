CREATE TABLE Asset (
	-- Asset has Asset ID
	AssetID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Asset over PresenceConstraint over (Asset ID in "Asset has Asset ID") occurs at most one time
	PRIMARY KEY(AssetID)
);


CREATE TABLE Claim (
	-- Claim has Claim ID
	ClaimID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Claim has p_sequence
	PSequence                               SMALLINT NOT NULL CHECK((PSequence >= 1 AND PSequence <= 999)),
	-- Claim is on Policy
	PolicyID                                BIGINT NOT NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is at Street
	IncidentAddressStreet                   VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is in City
	IncidentAddressCity                     VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in Postcode
	IncidentAddressPostcode                 VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in State
	IncidentAddressStateID                  BIGINT NULL,
	-- maybe Claim concerns Incident that relates to loss on Date Time
	IncidentDateTime                        TIMESTAMP NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was to officer-Name
	IncidentOfficerName                     VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe has police-Report Nr
	IncidentPoliceReportNr                  INTEGER NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was on report-Date Time
	IncidentReportDateTime                  TIMESTAMP NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was by reporter-Name
	IncidentReporterName                    VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that maybe is covered by Police Report that maybe was at station-Name
	IncidentStationName                     VARCHAR(256) NULL,
	-- maybe Lodgement involves Claim and Lodgement involves Person that is a kind of Party that has Party ID
	LodgementPersonID                       BIGINT NULL,
	-- maybe Lodgement involves Claim and maybe Lodgement was made at Date Time
	LodgementDateTime                       TIMESTAMP NULL,
	-- Primary index to Claim over PresenceConstraint over (Claim ID in "Claim has Claim ID") occurs at most one time
	PRIMARY KEY(ClaimID),
	-- Unique index to Claim over PresenceConstraint over (Policy, p_sequence in "Claim is on Policy", "Claim has Claim Sequence") occurs at most one time
	UNIQUE(PSequence, PolicyID)
);


CREATE TABLE ContractorAppointment (
	-- Contractor Appointment involves Claim that has Claim ID
	ClaimID                                 BIGINT NOT NULL,
	-- Contractor Appointment involves Contractor that is a kind of Company that is a kind of Party that has Party ID
	ContractorID                            BIGINT NOT NULL,
	-- Primary index to Contractor Appointment over PresenceConstraint over (Claim, Contractor in "Claim involves Contractor") occurs at most one time
	PRIMARY KEY(ClaimID, ContractorID),
	FOREIGN KEY (ClaimID) REFERENCES Claim (ClaimID)
);


CREATE TABLE Cover (
	-- Cover involves Policy
	PolicyID                                BIGINT NOT NULL,
	-- Cover involves Cover Type
	CoverTypeID                             BIGINT NOT NULL,
	-- Cover involves Asset that has Asset ID
	AssetID                                 BIGINT NOT NULL,
	-- Primary index to Cover over PresenceConstraint over (Policy, Cover Type, Asset in "Policy provides Cover Type over Asset") occurs at most one time
	PRIMARY KEY(PolicyID, CoverTypeID, AssetID),
	FOREIGN KEY (AssetID) REFERENCES Asset (AssetID)
);


CREATE TABLE CoverType (
	-- Cover Type surrogate key
	CoverTypeID                             BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Cover Type has Cover Type Code
	CoverTypeCode                           CHARACTER NOT NULL,
	-- Cover Type has Cover Type Name
	CoverTypeName                           VARCHAR NOT NULL,
	-- Primary index to Cover Type
	PRIMARY KEY(CoverTypeID),
	-- Unique index to Cover Type over PresenceConstraint over (Cover Type Code in "Cover Type has Cover Type Code") occurs at most one time
	UNIQUE(CoverTypeCode),
	-- Unique index to Cover Type over PresenceConstraint over (Cover Type Name in "Cover Type has Cover Type Name") occurs at most one time
	UNIQUE(CoverTypeName)
);


CREATE TABLE CoverWording (
	-- Cover Wording surrogate key
	CoverWordingID                          BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Cover Wording involves Cover Type
	CoverTypeID                             BIGINT NOT NULL,
	-- Cover Wording involves Policy Wording that has Policy Wording Text
	PolicyWordingText                       VARCHAR NOT NULL,
	-- Cover Wording involves start-Date
	StartDate                               DATE NOT NULL,
	-- Primary index to Cover Wording
	PRIMARY KEY(CoverWordingID),
	-- Unique index to Cover Wording over PresenceConstraint over (Cover Type, Policy Wording, Start Date in "Cover Type used Policy Wording from start-Date") occurs at most one time
	UNIQUE(CoverTypeID, PolicyWordingText, StartDate),
	FOREIGN KEY (CoverTypeID) REFERENCES CoverType (CoverTypeID)
);


CREATE TABLE LossType (
	-- Loss Type surrogate key
	LossTypeID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Loss Type has Loss Type Code
	LossTypeCode                            CHARACTER NOT NULL,
	-- Loss Type Involves Driving
	InvolvesDriving                         BOOLEAN,
	-- Loss Type Is Single Vehicle Incident
	IsSingleVehicleIncident                 BOOLEAN,
	-- maybe Loss Type implies Liability that has Liability Code
	LiabilityCode                           CHARACTER(1) NULL CHECK(LiabilityCode = 'D' OR LiabilityCode = 'L' OR LiabilityCode = 'R' OR LiabilityCode = 'U'),
	-- Primary index to Loss Type
	PRIMARY KEY(LossTypeID),
	-- Unique index to Loss Type over PresenceConstraint over (Loss Type Code in "Loss Type has Loss Type Code") occurs at most one time
	UNIQUE(LossTypeCode)
);


CREATE TABLE LostItem (
	-- Lost Item surrogate key
	LostItemID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Lost Item was lost in Incident that is of Claim that has Claim ID
	IncidentClaimID                         BIGINT NOT NULL,
	-- Lost Item has Lost Item Nr
	LostItemNr                              INTEGER NOT NULL,
	-- Lost Item has Description
	Description                             VARCHAR(1024) NOT NULL,
	-- maybe Lost Item was purchased on purchase-Date
	PurchaseDate                            DATE NULL,
	-- maybe Lost Item was purchased at purchase-Place
	PurchasePlace                           VARCHAR NULL,
	-- maybe Lost Item was purchased for purchase-Price
	PurchasePrice                           DECIMAL(18, 2) NULL,
	-- Primary index to Lost Item
	PRIMARY KEY(LostItemID),
	-- Unique index to Lost Item over PresenceConstraint over (Incident, Lost Item Nr in "Lost Item was lost in Incident", "Lost Item has Lost Item Nr") occurs at most one time
	UNIQUE(IncidentClaimID, LostItemNr),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID)
);


CREATE TABLE Party (
	-- Party has Party ID
	PartyID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Party Is A Company
	IsACompany                              BOOLEAN,
	-- maybe Party has postal-Address and Address is at Street
	PostalAddressStreet                     VARCHAR(256) NULL,
	-- maybe Party has postal-Address and Address is in City
	PostalAddressCity                       VARCHAR NULL,
	-- maybe Party has postal-Address and maybe Address is in Postcode
	PostalAddressPostcode                   VARCHAR NULL,
	-- maybe Party has postal-Address and maybe Address is in State
	PostalAddressStateID                    BIGINT NULL,
	-- maybe Party is a Company that has contact-Person and Person is a kind of Party that has Party ID
	CompanyContactPersonID                  BIGINT NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes business-Phone and Phone has Phone Nr
	PersonBusinessPhoneNr                   VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe prefers contact-Time
	PersonContactTime                       TIME NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes Email
	PersonEmail                             VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes home-Phone and Phone has Phone Nr
	PersonHomePhoneNr                       VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe includes mobile-Phone and Phone has Phone Nr
	PersonMobilePhoneNr                     VARCHAR NULL,
	-- maybe Party is a Person that has Contact Methods that maybe has preferred-Contact Method
	PersonPreferredContactMethod            CHARACTER(1) NULL CHECK(PersonPreferredContactMethod = 'B' OR PersonPreferredContactMethod = 'H' OR PersonPreferredContactMethod = 'M'),
	-- maybe Party is a Person that has family-Name
	PersonFamilyName                        VARCHAR(256) NULL,
	-- maybe Party is a Person that has given-Name
	PersonGivenName                         VARCHAR(256) NULL,
	-- maybe Party is a Person that has Title
	PersonTitle                             VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that is at Street
	PersonAddressStreet                     VARCHAR(256) NULL,
	-- maybe Party is a Person that maybe lives at Address that is in City
	PersonAddressCity                       VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that maybe is in Postcode
	PersonAddressPostcode                   VARCHAR NULL,
	-- maybe Party is a Person that maybe lives at Address that maybe is in State
	PersonAddressStateID                    BIGINT NULL,
	-- maybe Party is a Person that maybe has birth-Date
	PersonBirthDate                         DATE NULL,
	-- maybe Party is a Person that maybe holds License that Is International
	PersonIsInternational                   BOOLEAN,
	-- maybe Party is a Person that maybe holds License that has License Number
	PersonLicenseNumber                     VARCHAR NULL,
	-- maybe Party is a Person that maybe holds License that is of License Type
	PersonLicenseType                       VARCHAR NULL,
	-- maybe Party is a Person that maybe holds License that maybe was granted in Year that has Year Nr
	PersonYearNr                            INTEGER NULL,
	-- maybe Party is a Person that maybe has Occupation
	PersonOccupation                        VARCHAR NULL,
	-- Primary index to Party over PresenceConstraint over (Party ID in "Party has Party ID") occurs at most one time
	PRIMARY KEY(PartyID),
	FOREIGN KEY (CompanyContactPersonID) REFERENCES Party (PartyID)
);


CREATE TABLE Policy (
	-- Policy surrogate key
	PolicyID                                BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Policy was issued in p_year and Year has Year Nr
	PYearNr                                 INTEGER NOT NULL,
	-- Policy is for product having p_product
	PProductID                              BIGINT NOT NULL,
	-- Policy issued in state having p_state
	PStateID                                BIGINT NOT NULL,
	-- Policy has p_serial
	PSerial                                 INTEGER NOT NULL CHECK((PSerial >= 1 AND PSerial <= 99999)),
	-- Policy has Application that has Application Nr
	ApplicationNr                           INTEGER NOT NULL,
	-- Policy belongs to Insured that is a kind of Party that has Party ID
	InsuredID                               BIGINT NOT NULL,
	-- maybe Policy was sold by Authorised Rep that is a kind of Party that has Party ID
	AuthorisedRepID                         BIGINT NULL,
	-- maybe Policy has ITC Claimed
	ITCClaimed                              DECIMAL(18, 2) NULL CHECK((ITCClaimed >= 0.0 AND ITCClaimed <= 100.0)),
	-- Primary index to Policy
	PRIMARY KEY(PolicyID),
	-- Unique index to Policy over PresenceConstraint over (p_year, p_product, p_state, p_serial in "Policy was issued in Year", "Policy is for product having Product", "Policy issued in state having State", "Policy has Policy Serial") occurs at most one time
	UNIQUE(PYearNr, PProductID, PStateID, PSerial),
	FOREIGN KEY (AuthorisedRepID) REFERENCES Party (PartyID),
	FOREIGN KEY (InsuredID) REFERENCES Party (PartyID)
);


CREATE TABLE Product (
	-- Product surrogate key
	ProductID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Product has Product Code
	ProductCode                             SMALLINT NOT NULL CHECK((ProductCode >= 1 AND ProductCode <= 99)),
	-- maybe Product has Alias
	Alias                                   CHARACTER(3) NULL,
	-- maybe Product has Description
	Description                             VARCHAR(1024) NULL,
	-- Primary index to Product
	PRIMARY KEY(ProductID),
	-- Unique index to Product over PresenceConstraint over (Product Code in "Product has Product Code") occurs at most one time
	UNIQUE(ProductCode)
);

CREATE UNIQUE INDEX ProductByAlias ON Product(Alias) WHERE Alias IS NOT NULL;


CREATE UNIQUE INDEX ProductByDescription ON Product(Description) WHERE Description IS NOT NULL;


CREATE TABLE PropertyDamage (
	-- Property Damage surrogate key
	PropertyDamageID                        BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- maybe Property Damage was damaged in Incident that is of Claim that has Claim ID
	IncidentClaimID                         BIGINT NULL,
	-- Property Damage is at Address that is at Street
	AddressStreet                           VARCHAR(256) NOT NULL,
	-- Property Damage is at Address that is in City
	AddressCity                             VARCHAR NOT NULL,
	-- Property Damage is at Address that maybe is in Postcode
	AddressPostcode                         VARCHAR NULL,
	-- Property Damage is at Address that maybe is in State
	AddressStateID                          BIGINT NULL,
	-- maybe Property Damage belongs to owner-Name
	OwnerName                               VARCHAR(256) NULL,
	-- maybe Property Damage owner has contact Phone that has Phone Nr
	PhoneNr                                 VARCHAR NULL,
	-- Primary index to Property Damage
	PRIMARY KEY(PropertyDamageID),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID)
);

CREATE UNIQUE INDEX PropertyDamageByIncidentClaimIDAddressStreetAddressCityAd0ba ON PropertyDamage(IncidentClaimID, AddressStreet, AddressCity, AddressPostcode, AddressStateID) WHERE IncidentClaimID IS NOT NULL AND AddressPostcode IS NOT NULL AND AddressStateID IS NOT NULL;


CREATE TABLE "State" (
	-- State surrogate key
	StateID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- State has State Code
	StateCode                               SMALLINT NOT NULL CHECK((StateCode >= 0 AND StateCode <= 9)),
	-- maybe State has State Name
	StateName                               VARCHAR(256) NULL,
	-- Primary index to State
	PRIMARY KEY(StateID),
	-- Unique index to State over PresenceConstraint over (State Code in "State has State Code") occurs at most one time
	UNIQUE(StateCode)
);

CREATE UNIQUE INDEX StateByStateName ON "State"(StateName) WHERE StateName IS NOT NULL;


CREATE TABLE ThirdParty (
	-- Third Party surrogate key
	ThirdPartyID                            BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Third Party involves Person that is a kind of Party that has Party ID
	PersonID                                BIGINT NOT NULL,
	-- Third Party involves Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	VehicleIncidentClaimID                  BIGINT NOT NULL,
	-- maybe Third Party is insured by Insurer that is a kind of Company that is a kind of Party that has Party ID
	InsurerID                               BIGINT NULL,
	-- maybe Third Party vehicle is of model-Year and Year has Year Nr
	ModelYearNr                             INTEGER NULL,
	-- maybe Third Party drove vehicle-Registration and Registration has Registration Nr
	VehicleRegistrationNr                   CHARACTER(8) NULL,
	-- maybe Third Party vehicle is of Vehicle Type that is of Make
	VehicleTypeMake                         VARCHAR NULL,
	-- maybe Third Party vehicle is of Vehicle Type that is of Model
	VehicleTypeModel                        VARCHAR NULL,
	-- maybe Third Party vehicle is of Vehicle Type that maybe has Badge
	VehicleTypeBadge                        VARCHAR NULL,
	-- Primary index to Third Party
	PRIMARY KEY(ThirdPartyID),
	-- Unique index to Third Party over PresenceConstraint over (Person, Vehicle Incident in "Person was third party in Vehicle Incident") occurs at most one time
	UNIQUE(PersonID, VehicleIncidentClaimID),
	FOREIGN KEY (InsurerID) REFERENCES Party (PartyID),
	FOREIGN KEY (PersonID) REFERENCES Party (PartyID)
);


CREATE TABLE UnderwritingDemerit (
	-- Underwriting Demerit surrogate key
	UnderwritingDemeritID                   BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Underwriting Demerit preceded Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	VehicleIncidentClaimID                  BIGINT NOT NULL,
	-- Underwriting Demerit has Underwriting Question that has Underwriting Question ID
	UnderwritingQuestionID                  BIGINT NOT NULL,
	-- maybe Underwriting Demerit occurred occurrence-Count times
	OccurrenceCount                         INTEGER NULL,
	-- Primary index to Underwriting Demerit
	PRIMARY KEY(UnderwritingDemeritID),
	-- Unique index to Underwriting Demerit over PresenceConstraint over (Vehicle Incident, Underwriting Question in "Vehicle Incident occurred despite Underwriting Demerit", "Underwriting Demerit has Underwriting Question") occurs at most one time
	UNIQUE(VehicleIncidentClaimID, UnderwritingQuestionID)
);


CREATE TABLE UnderwritingQuestion (
	-- Underwriting Question has Underwriting Question ID
	UnderwritingQuestionID                  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Underwriting Question has Text
	Text                                    VARCHAR NOT NULL,
	-- Primary index to Underwriting Question over PresenceConstraint over (Underwriting Question ID in "Underwriting Question has Underwriting Question ID") occurs at most one time
	PRIMARY KEY(UnderwritingQuestionID),
	-- Unique index to Underwriting Question over PresenceConstraint over (Text in "Text is of Underwriting Question") occurs at most one time
	UNIQUE(Text)
);


CREATE TABLE Vehicle (
	-- Vehicle surrogate key
	VehicleID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Vehicle is a kind of Asset that has Asset ID
	AssetID                                 BIGINT NOT NULL,
	-- Vehicle has VIN
	VIN                                     INTEGER NOT NULL,
	-- Vehicle Has Commercial Registration
	HasCommercialRegistration               BOOLEAN,
	-- Vehicle is of model-Year and Year has Year Nr
	ModelYearNr                             INTEGER NOT NULL,
	-- Vehicle has Registration that has Registration Nr
	RegistrationNr                          CHARACTER(8) NOT NULL,
	-- Vehicle is of Vehicle Type that is of Make
	VehicleTypeMake                         VARCHAR NOT NULL,
	-- Vehicle is of Vehicle Type that is of Model
	VehicleTypeModel                        VARCHAR NOT NULL,
	-- Vehicle is of Vehicle Type that maybe has Badge
	VehicleTypeBadge                        VARCHAR NULL,
	-- maybe Vehicle is of Colour
	Colour                                  VARCHAR NULL,
	-- maybe Vehicle was sold by Dealer that is a kind of Party that has Party ID
	DealerID                                BIGINT NULL,
	-- maybe Vehicle has Engine Number
	EngineNumber                            VARCHAR NULL,
	-- maybe Vehicle is subject to finance with Finance Institution that is a kind of Company that is a kind of Party that has Party ID
	FinanceInstitutionID                    BIGINT NULL,
	-- Primary index to Vehicle
	PRIMARY KEY(VehicleID),
	-- Unique index to Vehicle over PresenceConstraint over (Asset in "Vehicle is a kind of Asset") occurs at most one time
	UNIQUE(AssetID),
	-- Unique index to Vehicle over PresenceConstraint over (VIN in "Vehicle has VIN") occurs at most one time
	UNIQUE(VIN),
	FOREIGN KEY (AssetID) REFERENCES Asset (AssetID),
	FOREIGN KEY (DealerID) REFERENCES Party (PartyID),
	FOREIGN KEY (FinanceInstitutionID) REFERENCES Party (PartyID)
);


CREATE TABLE VehicleIncident (
	-- Vehicle Incident is a kind of Incident that is of Claim that has Claim ID
	IncidentClaimID                         BIGINT NOT NULL,
	-- Vehicle Incident Occurred While Being Driven
	OccurredWhileBeingDriven                BOOLEAN,
	-- maybe Vehicle Incident has Description
	Description                             VARCHAR(1024) NULL,
	-- maybe Driving involves Vehicle Incident and Driving was by Person that is a kind of Party that has Party ID
	DrivingPersonID                         BIGINT NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving resulted in breath-Test Result
	DrivingBreathTestResult                 VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving Charge involves Driving that Is A Warning
	DrivingIsAWarning                       BOOLEAN,
	-- maybe Driving involves Vehicle Incident and maybe Driving Charge involves Driving and Driving Charge involves Charge
	DrivingCharge                           VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Hospitalization involves Driving and Hospitalization involves Hospital that has Hospital Name
	DrivingHospitalName                     VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Hospitalization involves Driving and maybe Hospitalization resulted in blood-Test Result
	DrivingBloodTestResult                  VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving followed Intoxication
	DrivingIntoxication                     VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving was without owners consent for nonconsent-Reason
	DrivingNonconsentReason                 VARCHAR NULL,
	-- maybe Driving involves Vehicle Incident and maybe Driving was unlicenced for unlicensed-Reason
	DrivingUnlicensedReason                 VARCHAR NULL,
	-- maybe Vehicle Incident resulted from Loss Type
	LossTypeID                              BIGINT NULL,
	-- maybe Vehicle Incident involved previous_damage-Description
	PreviousDamageDescription               VARCHAR(1024) NULL,
	-- maybe Vehicle Incident was caused by Reason
	Reason                                  VARCHAR NULL,
	-- maybe Vehicle Incident resulted in vehicle being towed to towed-Location
	TowedLocation                           VARCHAR NULL,
	-- maybe Vehicle Incident occurred during weather-Description
	WeatherDescription                      VARCHAR(1024) NULL,
	-- Primary index to Vehicle Incident over PresenceConstraint over (Incident in "Vehicle Incident is a kind of Incident") occurs at most one time
	PRIMARY KEY(IncidentClaimID),
	FOREIGN KEY (DrivingPersonID) REFERENCES Party (PartyID),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID),
	FOREIGN KEY (LossTypeID) REFERENCES LossType (LossTypeID)
);


CREATE TABLE Witness (
	-- Witness surrogate key
	WitnessID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Witness saw Incident that is of Claim that has Claim ID
	IncidentClaimID                         BIGINT NOT NULL,
	-- Witness is called Name
	Name                                    VARCHAR(256) NOT NULL,
	-- maybe Witness lives at Address that is at Street
	AddressStreet                           VARCHAR(256) NULL,
	-- maybe Witness lives at Address that is in City
	AddressCity                             VARCHAR NULL,
	-- maybe Witness lives at Address that maybe is in Postcode
	AddressPostcode                         VARCHAR NULL,
	-- maybe Witness lives at Address that maybe is in State
	AddressStateID                          BIGINT NULL,
	-- maybe Witness has contact-Phone and Phone has Phone Nr
	ContactPhoneNr                          VARCHAR NULL,
	-- Primary index to Witness
	PRIMARY KEY(WitnessID),
	-- Unique index to Witness over PresenceConstraint over (Incident, Name in "Incident was independently witnessed by Witness", "Witness is called Name") occurs at most one time
	UNIQUE(IncidentClaimID, Name),
	FOREIGN KEY (AddressStateID) REFERENCES "State" (StateID),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID)
);


ALTER TABLE Claim
	ADD FOREIGN KEY (IncidentAddressStateID) REFERENCES "State" (StateID);


ALTER TABLE Claim
	ADD FOREIGN KEY (LodgementPersonID) REFERENCES Party (PartyID);


ALTER TABLE Claim
	ADD FOREIGN KEY (PolicyID) REFERENCES Policy (PolicyID);


ALTER TABLE ContractorAppointment
	ADD FOREIGN KEY (ContractorID) REFERENCES Party (PartyID);


ALTER TABLE Cover
	ADD FOREIGN KEY (CoverTypeID) REFERENCES CoverType (CoverTypeID);


ALTER TABLE Cover
	ADD FOREIGN KEY (PolicyID) REFERENCES Policy (PolicyID);


ALTER TABLE Party
	ADD FOREIGN KEY (PersonAddressStateID) REFERENCES "State" (StateID);


ALTER TABLE Party
	ADD FOREIGN KEY (PostalAddressStateID) REFERENCES "State" (StateID);


ALTER TABLE Policy
	ADD FOREIGN KEY (PProductID) REFERENCES Product (ProductID);


ALTER TABLE Policy
	ADD FOREIGN KEY (PStateID) REFERENCES "State" (StateID);


ALTER TABLE PropertyDamage
	ADD FOREIGN KEY (AddressStateID) REFERENCES "State" (StateID);


ALTER TABLE ThirdParty
	ADD FOREIGN KEY (VehicleIncidentClaimID) REFERENCES VehicleIncident (IncidentClaimID);


ALTER TABLE UnderwritingDemerit
	ADD FOREIGN KEY (UnderwritingQuestionID) REFERENCES UnderwritingQuestion (UnderwritingQuestionID);


ALTER TABLE UnderwritingDemerit
	ADD FOREIGN KEY (VehicleIncidentClaimID) REFERENCES VehicleIncident (IncidentClaimID);

