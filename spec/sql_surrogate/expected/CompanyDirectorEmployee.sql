CREATE TABLE Attendance (
	-- Attendance involves Attendee
	AttendeePersonID                        BIGINT NOT NULL,
	-- Attendance involves Meeting
	MeetingID                               BIGINT NOT NULL,
	-- Primary index to Attendance over PresenceConstraint over (Attendee, Meeting in "Person attended Meeting") occurs at most one time
	PRIMARY KEY(AttendeePersonID, MeetingID)
);


CREATE TABLE Company (
	-- Company surrogate key
	CompanyID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Company is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- Company Is Listed
	IsListed                                BOOLEAN,
	-- Primary index to Company
	PRIMARY KEY(CompanyID),
	-- Unique index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
	UNIQUE(CompanyName)
);


CREATE TABLE Directorship (
	-- Directorship surrogate key
	DirectorshipID                          BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Directorship involves Director
	DirectorPersonID                        BIGINT NOT NULL,
	-- Directorship involves Company
	CompanyID                               BIGINT NOT NULL,
	-- Directorship began on appointment-Date
	AppointmentDate                         DATE NOT NULL,
	-- Primary index to Directorship
	PRIMARY KEY(DirectorshipID),
	-- Unique index to Directorship over PresenceConstraint over (Director, Company in "Person directs Company") occurs at most one time
	UNIQUE(DirectorPersonID, CompanyID),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID)
);


CREATE TABLE Employee (
	-- Employee surrogate key
	EmployeeID                              BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Employee has Employee Nr
	EmployeeNr                              INTEGER NOT NULL,
	-- Employee works at Company
	CompanyID                               BIGINT NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee
	ManagerEmployeeID                       BIGINT NULL,
	-- maybe Employee is a Manager that Is Ceo
	ManagerIsCeo                            BOOLEAN,
	-- Primary index to Employee
	PRIMARY KEY(EmployeeID),
	-- Unique index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
	UNIQUE(EmployeeNr),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID),
	FOREIGN KEY (ManagerEmployeeID) REFERENCES Employee (EmployeeID)
);


CREATE TABLE Employment (
	-- Employment involves Person
	PersonID                                BIGINT NOT NULL,
	-- Employment involves Employee
	EmployeeID                              BIGINT NOT NULL,
	-- Primary index to Employment over PresenceConstraint over (Person, Employee in "Person works as Employee") occurs at most one time
	PRIMARY KEY(PersonID, EmployeeID),
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);


CREATE TABLE Meeting (
	-- Meeting surrogate key
	MeetingID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Meeting is held by Company
	CompanyID                               BIGINT NOT NULL,
	-- Meeting is held on Date
	"Date"                                  DATE NOT NULL,
	-- Is Board Meeting
	IsBoardMeeting                          BOOLEAN,
	-- Primary index to Meeting
	PRIMARY KEY(MeetingID),
	-- Unique index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	UNIQUE(CompanyID, "Date", IsBoardMeeting),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID)
);


CREATE TABLE Person (
	-- Person surrogate key
	PersonID                                BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Person has given-Name
	GivenName                               VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	FamilyName                              VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	BirthDate                               DATE NULL CHECK(BirthDate >= '1900/01/01'),
	-- Primary index to Person
	PRIMARY KEY(PersonID)
);

CREATE UNIQUE INDEX PersonByGivenNameFamilyName ON Person(GivenName, FamilyName) WHERE FamilyName IS NOT NULL;


ALTER TABLE Attendance
	ADD FOREIGN KEY (AttendeePersonID) REFERENCES Person (PersonID);


ALTER TABLE Attendance
	ADD FOREIGN KEY (MeetingID) REFERENCES Meeting (MeetingID);


ALTER TABLE Directorship
	ADD FOREIGN KEY (DirectorPersonID) REFERENCES Person (PersonID);


ALTER TABLE Employment
	ADD FOREIGN KEY (PersonID) REFERENCES Person (PersonID);

