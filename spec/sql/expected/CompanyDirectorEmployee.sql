CREATE TABLE Attendance (
	-- Attendance involves Attendee and Person has given-Name
	AttendeeGivenName                       VARCHAR(48) NOT NULL,
	-- Attendance involves Attendee and maybe Person is called family-Name
	AttendeeFamilyName                      VARCHAR(48) NULL,
	-- Attendance involves Meeting that is held by Company that is called Company Name
	MeetingCompanyName                      VARCHAR(48) NOT NULL,
	-- Attendance involves Meeting that is held on Date
	MeetingDate                             DATE NOT NULL,
	-- Attendance involves Meeting that Is Board Meeting
	MeetingIsBoardMeeting                   BOOLEAN,
	-- Primary index to Attendance over PresenceConstraint over (Attendee, Meeting in "Person attended Meeting") occurs at most one time
	UNIQUE(AttendeeGivenName, AttendeeFamilyName, MeetingCompanyName, MeetingDate, MeetingIsBoardMeeting)
);


CREATE TABLE Company (
	-- Company is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- Company Is Listed
	IsListed                                BOOLEAN,
	-- Primary index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
	PRIMARY KEY(CompanyName)
);


CREATE TABLE Directorship (
	-- Directorship involves Director and Person has given-Name
	DirectorGivenName                       VARCHAR(48) NOT NULL,
	-- Directorship involves Director and maybe Person is called family-Name
	DirectorFamilyName                      VARCHAR(48) NULL,
	-- Directorship involves Company that is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- Directorship began on appointment-Date
	AppointmentDate                         DATE NOT NULL,
	-- Primary index to Directorship over PresenceConstraint over (Director, Company in "Person directs Company") occurs at most one time
	UNIQUE(DirectorGivenName, DirectorFamilyName, CompanyName),
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName)
);


CREATE TABLE Employee (
	-- Employee has Employee Nr
	EmployeeNr                              INTEGER NOT NULL,
	-- Employee works at Company that is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee that has Employee Nr
	ManagerNr                               INTEGER NULL,
	-- maybe Employee is a Manager that Is Ceo
	ManagerIsCeo                            BOOLEAN,
	-- Primary index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
	PRIMARY KEY(EmployeeNr),
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName),
	FOREIGN KEY (ManagerNr) REFERENCES Employee (EmployeeNr)
);


CREATE TABLE Employment (
	-- Employment involves Person that has given-Name
	PersonGivenName                         VARCHAR(48) NOT NULL,
	-- Employment involves Person that maybe is called family-Name
	PersonFamilyName                        VARCHAR(48) NULL,
	-- Employment involves Employee that has Employee Nr
	EmployeeNr                              INTEGER NOT NULL,
	-- Primary index to Employment over PresenceConstraint over (Person, Employee in "Person works as Employee") occurs at most one time
	UNIQUE(PersonGivenName, PersonFamilyName, EmployeeNr),
	FOREIGN KEY (EmployeeNr) REFERENCES Employee (EmployeeNr)
);


CREATE TABLE Meeting (
	-- Meeting is held by Company that is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- Meeting is held on Date
	"Date"                                  DATE NOT NULL,
	-- Is Board Meeting
	IsBoardMeeting                          BOOLEAN,
	-- Primary index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	PRIMARY KEY(CompanyName, "Date", IsBoardMeeting),
	FOREIGN KEY (CompanyName) REFERENCES Company (CompanyName)
);


CREATE TABLE Person (
	-- Person has given-Name
	GivenName                               VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	FamilyName                              VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	BirthDate                               DATE NULL CHECK(BirthDate >= '1900/01/01'),
	-- Primary index to Person over PresenceConstraint over (Given Name, Family Name in "Person has given-Name", "family-Name is of Person") occurs at most one time
	UNIQUE(GivenName, FamilyName)
);


ALTER TABLE Attendance
	ADD FOREIGN KEY (AttendeeGivenName, AttendeeFamilyName) REFERENCES Person (GivenName, FamilyName);


ALTER TABLE Attendance
	ADD FOREIGN KEY (MeetingCompanyName, MeetingDate, MeetingIsBoardMeeting) REFERENCES Meeting (CompanyName, "Date", IsBoardMeeting);


ALTER TABLE Directorship
	ADD FOREIGN KEY (DirectorGivenName, DirectorFamilyName) REFERENCES Person (GivenName, FamilyName);


ALTER TABLE Employment
	ADD FOREIGN KEY (PersonGivenName, PersonFamilyName) REFERENCES Person (GivenName, FamilyName);

