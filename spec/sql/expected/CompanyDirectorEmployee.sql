CREATE TABLE Attendance (
	-- Attendance involves Person and Person has given-Name
	AttendeeGivenName                       varchar(48) NULL,
	-- Attendance involves Person and maybe Person is called family-Name
	AttendeeFamilyName                      varchar(48) NOT NULL,
	-- Attendance involves Meeting that is held by Company that is called Company Name
	MeetingCompanyName                      varchar(48) NULL,
	-- Attendance involves Meeting that is held on Date
	MeetingDate                             datetime NULL,
	-- Is Board Meeting
	MeetingIsBoardMeeting                   BOOLEAN
)
GO
CREATE UNIQUE CLUSTERED INDEX AttendanceByAttendeeGivenNameAttendeeFamilyNameMeetingCo7611 ON (AttendeeGivenName, AttendeeFamilyName, MeetingCompanyName, MeetingDate, MeetingIsBoardMeeting) WHERE AttendeeFamilyName IS NOT NULL
GO

CREATE TABLE Company (
	-- Company is called Company Name
	CompanyName                             varchar(48) NULL,
	-- Is Listed
	IsListed                                BOOLEAN,
	-- Primary index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
	PRIMARY KEY CLUSTERED(CompanyName)
)
GO

CREATE TABLE Directorship (
	-- Directorship involves Person and Person has given-Name
	DirectorGivenName                       varchar(48) NULL,
	-- Directorship involves Person and maybe Person is called family-Name
	DirectorFamilyName                      varchar(48) NOT NULL,
	-- Directorship involves Company that is called Company Name
	CompanyName                             varchar(48) NULL,
	-- Directorship began on appointment-Date
	AppointmentDate                         datetime NULL,
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName)
)
GO
CREATE UNIQUE CLUSTERED INDEX DirectorshipByDirectorGivenNameDirectorFamilyNameCompanyName ON (DirectorGivenName, DirectorFamilyName, CompanyName) WHERE DirectorFamilyName IS NOT NULL
GO

CREATE TABLE Employee (
	-- Employee has Employee Nr
	EmployeeNr                              int NULL,
	-- Employee works at Company that is called Company Name
	CompanyName                             varchar(48) NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee that has Employee Nr
	ManagerNr                               int NOT NULL,
	-- Is Ceo
	ManagerIsCeo                            BOOLEAN,
	-- Primary index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
	PRIMARY KEY CLUSTERED(EmployeeNr),
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName),
	FOREIGN KEY (ManagerNr) REFERENCES Employee (EmployeeNr)
)
GO

CREATE TABLE Employment (
	-- Employment involves Person that has given-Name
	PersonGivenName                         varchar(48) NULL,
	-- Employment involves Person that maybe is called family-Name
	PersonFamilyName                        varchar(48) NOT NULL,
	-- Employment involves Employee that has Employee Nr
	EmployeeNr                              int NULL,
	FOREIGN KEY (EmployeeNr) REFERENCES Employee (EmployeeNr)
)
GO
CREATE UNIQUE CLUSTERED INDEX EmploymentByPersonGivenNamePersonFamilyNameEmployeeNr ON (PersonGivenName, PersonFamilyName, EmployeeNr) WHERE PersonFamilyName IS NOT NULL
GO

CREATE TABLE Meeting (
	-- Meeting is held by Company that is called Company Name
	CompanyName                             varchar(48) NULL,
	-- Meeting is held on Date
	Date                                    datetime NULL,
	-- Is Board Meeting
	IsBoardMeeting                          BOOLEAN,
	-- Primary index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	PRIMARY KEY CLUSTERED(CompanyName, Date, IsBoardMeeting),
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName)
)
GO

CREATE TABLE Person (
	-- Person has given-Name
	GivenName                               varchar(48) NULL,
	-- maybe Person is called family-Name
	FamilyName                              varchar(48) NOT NULL,
	-- maybe Person was born on birth-Date
	BirthDate                               datetime NOT NULL CHECK(BirthDate >= '1900/01/01')
)
GO
CREATE UNIQUE CLUSTERED INDEX PersonByGivenNameFamilyName ON (GivenName, FamilyName) WHERE FamilyName IS NOT NULL
GO

ALTER TABLE Meeting
	ADD FOREIGN KEY (MeetingCompanyName, MeetingDate, MeetingIsBoardMeeting) REFERENCES Meeting (CompanyName, Date, IsBoardMeeting)
GO

ALTER TABLE Person
	ADD FOREIGN KEY (AttendeeGivenName, AttendeeFamilyName) REFERENCES Person (GivenName, FamilyName)
GO

ALTER TABLE Person
	ADD FOREIGN KEY (DirectorGivenName, DirectorFamilyName) REFERENCES Person (GivenName, FamilyName)
GO

ALTER TABLE Person
	ADD FOREIGN KEY (PersonGivenName, PersonFamilyName) REFERENCES Person (GivenName, FamilyName)
GO
