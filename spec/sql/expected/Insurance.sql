CREATE TABLE Asset (
	-- Asset has Asset ID
	AssetID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Asset(Asset ID in "Asset has Asset ID")
	PRIMARY KEY(AssetID)
);


CREATE TABLE Claim (
	-- Claim has Claim ID
	ClaimID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Claim has p_sequence
	PSequence                               SMALLINT NOT NULL CHECK((PSequence >= 1 AND PSequence <= 999)),
	-- Claim is on Policy that was issued in p_year and Year has Year Nr
	PolicyPYearNr                           INTEGER NOT NULL,
	-- Claim is on Policy that is for product having p_product and Product has Product Code
	PolicyPProductCode                      SMALLINT NOT NULL CHECK((PolicyPProductCode >= 1 AND PolicyPProductCode <= 99)),
	-- Claim is on Policy that issued in state having p_state and State has State Code
	PolicyPStateCode                        SMALLINT NOT NULL CHECK((PolicyPStateCode >= 0 AND PolicyPStateCode <= 9)),
	-- Claim is on Policy that has p_serial
	PolicyPSerial                           INTEGER NOT NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is at Street
	IncidentAddressStreet                   VARCHAR(256) NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that is in City
	IncidentAddressCity                     VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in Postcode
	IncidentAddressPostcode                 VARCHAR NULL,
	-- maybe Claim concerns Incident that relates to loss at Address that maybe is in State that has State Code
	IncidentAddressStateCode                SMALLINT NULL,
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
	-- Primary index to Claim(Claim ID in "Claim has Claim ID")
	PRIMARY KEY(ClaimID),
	-- Unique index to Claim(Policy, p_sequence in "Claim is on Policy", "Claim has Claim Sequence")
	UNIQUE(PolicyPYearNr, PolicyPProductCode, PolicyPStateCode, PolicyPSerial, PSequence)
);


CREATE TABLE ContractorAppointment (
	-- Contractor Appointment involves Claim that has Claim ID
	ClaimID                                 BIGINT NOT NULL,
	-- Contractor Appointment involves Contractor that is a kind of Company that is a kind of Party that has Party ID
	ContractorID                            BIGINT NOT NULL,
	-- Primary index to Contractor Appointment(Claim, Contractor in "Claim involves Contractor")
	PRIMARY KEY(ClaimID, ContractorID),
	FOREIGN KEY (ClaimID) REFERENCES Claim (ClaimID)
);


CREATE TABLE Cover (
	-- Cover involves Policy that was issued in p_year and Year has Year Nr
	PolicyPYearNr                           INTEGER NOT NULL,
	-- Cover involves Policy that is for product having p_product and Product has Product Code
	PolicyPProductCode                      SMALLINT NOT NULL CHECK((PolicyPProductCode >= 1 AND PolicyPProductCode <= 99)),
	-- Cover involves Policy that issued in state having p_state and State has State Code
	PolicyPStateCode                        SMALLINT NOT NULL CHECK((PolicyPStateCode >= 0 AND PolicyPStateCode <= 9)),
	-- Cover involves Policy that has p_serial
	PolicyPSerial                           INTEGER NOT NULL,
	-- Cover involves Cover Type that has Cover Type Code
	CoverTypeCode                           CHARACTER NOT NULL,
	-- Cover involves Asset that has Asset ID
	AssetID                                 BIGINT NOT NULL,
	-- Primary index to Cover(Policy, Cover Type, Asset in "Policy provides Cover Type over Asset")
	PRIMARY KEY(PolicyPYearNr, PolicyPProductCode, PolicyPStateCode, PolicyPSerial, CoverTypeCode, AssetID),
	FOREIGN KEY (AssetID) REFERENCES Asset (AssetID)
);


CREATE TABLE CoverType (
	-- Cover Type has Cover Type Code
	CoverTypeCode                           CHARACTER NOT NULL,
	-- Cover Type has Cover Type Name
	CoverTypeName                           VARCHAR NOT NULL,
	-- Primary index to Cover Type(Cover Type Code in "Cover Type has Cover Type Code")
	PRIMARY KEY(CoverTypeCode),
	-- Unique index to Cover Type(Cover Type Name in "Cover Type has Cover Type Name")
	UNIQUE(CoverTypeName)
);


CREATE TABLE CoverWording (
	-- Cover Wording involves Cover Type that has Cover Type Code
	CoverTypeCode                           CHARACTER NOT NULL,
	-- Cover Wording involves Policy Wording that has Policy Wording Text
	PolicyWordingText                       VARCHAR NOT NULL,
	-- Cover Wording involves start-Date
	StartDate                               DATE NOT NULL,
	-- Primary index to Cover Wording(Cover Type, Policy Wording, Start Date in "Cover Type used Policy Wording from start-Date")
	PRIMARY KEY(CoverTypeCode, PolicyWordingText, StartDate),
	FOREIGN KEY (CoverTypeCode) REFERENCES CoverType (CoverTypeCode)
);


CREATE TABLE LossType (
	-- Loss Type has Loss Type Code
	LossTypeCode                            CHARACTER NOT NULL,
	-- Loss Type Involves Driving
	InvolvesDriving                         BOOLEAN,
	-- Loss Type Is Single Vehicle Incident
	IsSingleVehicleIncident                 BOOLEAN,
	-- maybe Loss Type implies Liability that has Liability Code
	LiabilityCode                           CHARACTER(1) NULL CHECK(LiabilityCode = 'D' OR LiabilityCode = 'L' OR LiabilityCode = 'R' OR LiabilityCode = 'U'),
	-- Primary index to Loss Type(Loss Type Code in "Loss Type has Loss Type Code")
	PRIMARY KEY(LossTypeCode)
);


CREATE TABLE LostItem (
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
	-- Primary index to Lost Item(Incident, Lost Item Nr in "Lost Item was lost in Incident", "Lost Item has Lost Item Nr")
	PRIMARY KEY(IncidentClaimID, LostItemNr),
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
	-- maybe Party has postal-Address and maybe Address is in State that has State Code
	PostalAddressStateCode                  SMALLINT NULL,
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
	-- maybe Party is a Person that maybe lives at Address that maybe is in State that has State Code
	PersonAddressStateCode                  SMALLINT NULL,
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
	-- Primary index to Party(Party ID in "Party has Party ID")
	PRIMARY KEY(PartyID),
	FOREIGN KEY (CompanyContactPersonID) REFERENCES Party (PartyID)
);


CREATE TABLE Policy (
	-- Policy was issued in p_year and Year has Year Nr
	PYearNr                                 INTEGER NOT NULL,
	-- Policy is for product having p_product and Product has Product Code
	PProductCode                            SMALLINT NOT NULL,
	-- Policy issued in state having p_state and State has State Code
	PStateCode                              SMALLINT NOT NULL,
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
	-- Primary index to Policy(p_year, p_product, p_state, p_serial in "Policy was issued in Year", "Policy is for product having Product", "Policy issued in state having State", "Policy has Policy Serial")
	PRIMARY KEY(PYearNr, PProductCode, PStateCode, PSerial),
	FOREIGN KEY (AuthorisedRepID) REFERENCES Party (PartyID),
	FOREIGN KEY (InsuredID) REFERENCES Party (PartyID)
);


CREATE TABLE Product (
	-- Product has Product Code
	ProductCode                             SMALLINT NOT NULL CHECK((ProductCode >= 1 AND ProductCode <= 99)),
	-- maybe Product has Alias
	Alias                                   CHARACTER(3) NULL,
	-- maybe Product has Description
	Description                             VARCHAR(1024) NULL,
	-- Primary index to Product(Product Code in "Product has Product Code")
	PRIMARY KEY(ProductCode),
	-- Unique index to Product(Alias in "Alias is of Product")
	UNIQUE(Alias),
	-- Unique index to Product(Description in "Description is of Product")
	UNIQUE(Description)
);


CREATE TABLE PropertyDamage (
	-- maybe Property Damage was damaged in Incident that is of Claim that has Claim ID
	IncidentClaimID                         BIGINT NULL,
	-- Property Damage is at Address that is at Street
	AddressStreet                           VARCHAR(256) NOT NULL,
	-- Property Damage is at Address that is in City
	AddressCity                             VARCHAR NOT NULL,
	-- Property Damage is at Address that maybe is in Postcode
	AddressPostcode                         VARCHAR NULL,
	-- Property Damage is at Address that maybe is in State that has State Code
	AddressStateCode                        SMALLINT NULL,
	-- maybe Property Damage belongs to owner-Name
	OwnerName                               VARCHAR(256) NULL,
	-- maybe Property Damage owner has contact Phone that has Phone Nr
	PhoneNr                                 VARCHAR NULL,
	-- Primary index to Property Damage(Incident, Address in "Incident caused Property Damage", "Property Damage is at Address")
	UNIQUE(IncidentClaimID, AddressStreet, AddressCity, AddressPostcode, AddressStateCode),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID)
);


CREATE TABLE State (
	-- State has State Code
	StateCode                               SMALLINT NOT NULL CHECK((StateCode >= 0 AND StateCode <= 9)),
	-- maybe State has State Name
	StateName                               VARCHAR(256) NULL,
	-- Primary index to State(State Code in "State has State Code")
	PRIMARY KEY(StateCode),
	-- Unique index to State(State Name in "State Name is of State")
	UNIQUE(StateName)
);


CREATE TABLE ThirdParty (
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
	-- Primary index to Third Party(Person, Vehicle Incident in "Person was third party in Vehicle Incident")
	PRIMARY KEY(PersonID, VehicleIncidentClaimID),
	FOREIGN KEY (InsurerID) REFERENCES Party (PartyID),
	FOREIGN KEY (PersonID) REFERENCES Party (PartyID)
);


CREATE TABLE UnderwritingDemerit (
	-- Underwriting Demerit preceded Vehicle Incident that is a kind of Incident that is of Claim that has Claim ID
	VehicleIncidentClaimID                  BIGINT NOT NULL,
	-- Underwriting Demerit has Underwriting Question that has Underwriting Question ID
	UnderwritingQuestionID                  BIGINT NOT NULL,
	-- maybe Underwriting Demerit occurred occurrence-Count times
	OccurrenceCount                         INTEGER NULL,
	-- Primary index to Underwriting Demerit(Vehicle Incident, Underwriting Question in "Vehicle Incident occurred despite Underwriting Demerit", "Underwriting Demerit has Underwriting Question")
	PRIMARY KEY(VehicleIncidentClaimID, UnderwritingQuestionID)
);


CREATE TABLE UnderwritingQuestion (
	-- Underwriting Question has Underwriting Question ID
	UnderwritingQuestionID                  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Underwriting Question has Text
	Text                                    VARCHAR NOT NULL,
	-- Primary index to Underwriting Question(Underwriting Question ID in "Underwriting Question has Underwriting Question ID")
	PRIMARY KEY(UnderwritingQuestionID),
	-- Unique index to Underwriting Question(Text in "Text is of Underwriting Question")
	UNIQUE(Text)
);


CREATE TABLE Vehicle (
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
	-- Primary index to Vehicle(VIN in "Vehicle has VIN")
	PRIMARY KEY(VIN),
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
	-- maybe Vehicle Incident resulted from Loss Type that has Loss Type Code
	LossTypeCode                            CHARACTER NULL,
	-- maybe Vehicle Incident involved previous_damage-Description
	PreviousDamageDescription               VARCHAR(1024) NULL,
	-- maybe Vehicle Incident was caused by Reason
	Reason                                  VARCHAR NULL,
	-- maybe Vehicle Incident resulted in vehicle being towed to towed-Location
	TowedLocation                           VARCHAR NULL,
	-- maybe Vehicle Incident occurred during weather-Description
	WeatherDescription                      VARCHAR(1024) NULL,
	-- Primary index to Vehicle Incident(Incident in "Vehicle Incident is a kind of Incident")
	PRIMARY KEY(IncidentClaimID),
	FOREIGN KEY (DrivingPersonID) REFERENCES Party (PartyID),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID),
	FOREIGN KEY (LossTypeCode) REFERENCES LossType (LossTypeCode)
);


CREATE TABLE Witness (
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
	-- maybe Witness lives at Address that maybe is in State that has State Code
	AddressStateCode                        SMALLINT NULL,
	-- maybe Witness has contact-Phone and Phone has Phone Nr
	ContactPhoneNr                          VARCHAR NULL,
	-- Primary index to Witness(Incident, Name in "Incident was independently witnessed by Witness", "Witness is called Name")
	PRIMARY KEY(IncidentClaimID, Name),
	FOREIGN KEY (AddressStateCode) REFERENCES State (StateCode),
	FOREIGN KEY (IncidentClaimID) REFERENCES Claim (ClaimID)
);


ALTER TABLE Claim
	ADD FOREIGN KEY (IncidentAddressStateCode) REFERENCES State (StateCode);

ALTER TABLE Claim
	ADD FOREIGN KEY (LodgementPersonID) REFERENCES Party (PartyID);

ALTER TABLE Claim
	ADD FOREIGN KEY (PolicyPYearNr, PolicyPProductCode, PolicyPStateCode, PolicyPSerial) REFERENCES Policy (PYearNr, PProductCode, PStateCode, PSerial);

ALTER TABLE ContractorAppointment
	ADD FOREIGN KEY (ContractorID) REFERENCES Party (PartyID);

ALTER TABLE Cover
	ADD FOREIGN KEY (CoverTypeCode) REFERENCES CoverType (CoverTypeCode);

ALTER TABLE Cover
	ADD FOREIGN KEY (PolicyPYearNr, PolicyPProductCode, PolicyPStateCode, PolicyPSerial) REFERENCES Policy (PYearNr, PProductCode, PStateCode, PSerial);

ALTER TABLE Party
	ADD FOREIGN KEY (PersonAddressStateCode) REFERENCES State (StateCode);

ALTER TABLE Party
	ADD FOREIGN KEY (PostalAddressStateCode) REFERENCES State (StateCode);

ALTER TABLE Policy
	ADD FOREIGN KEY (PProductCode) REFERENCES Product (ProductCode);

ALTER TABLE Policy
	ADD FOREIGN KEY (PStateCode) REFERENCES State (StateCode);

ALTER TABLE PropertyDamage
	ADD FOREIGN KEY (AddressStateCode) REFERENCES State (StateCode);

ALTER TABLE ThirdParty
	ADD FOREIGN KEY (VehicleIncidentClaimID) REFERENCES VehicleIncident (IncidentClaimID);

ALTER TABLE UnderwritingDemerit
	ADD FOREIGN KEY (UnderwritingQuestionID) REFERENCES UnderwritingQuestion (UnderwritingQuestionID);

ALTER TABLE UnderwritingDemerit
	ADD FOREIGN KEY (VehicleIncidentClaimID) REFERENCES VehicleIncident (IncidentClaimID);
