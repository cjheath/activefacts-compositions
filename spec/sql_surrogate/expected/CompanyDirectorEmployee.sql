CREATE TABLE Attendance (
	-- Person ID
	AttendeePersonID                        BIGINT IDENTITY NOT NULL,
	-- Meeting ID
	MeetingID                               BIGINT IDENTITY NOT NULL,
	-- Primary index to Attendance over PresenceConstraint over (Attendee, Meeting in "Person attended Meeting") occurs at most one time
	PRIMARY KEY CLUSTERED(AttendeePersonID, MeetingID)
);


CREATE TABLE Company (
	-- Company ID
	CompanyID                               BIGINT IDENTITY NOT NULL,
	-- Company is called Company Name
	CompanyName                             VARCHAR(48) NOT NULL,
	-- Is Listed
	IsListed                                BOOLEAN,
	-- Primary index to Company
	PRIMARY KEY CLUSTERED(CompanyID),
	-- Unique index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
	UNIQUE NONCLUSTERED(CompanyName)
);


CREATE TABLE Directorship (
	-- Directorship ID
	DirectorshipID                          BIGINT IDENTITY NOT NULL,
	-- Person ID
	DirectorPersonID                        BIGINT IDENTITY NOT NULL,
	-- Company ID
	CompanyID                               BIGINT IDENTITY NOT NULL,
	-- Directorship began on appointment-Date
	AppointmentDate                         DATE NOT NULL,
	-- Primary index to Directorship
	PRIMARY KEY CLUSTERED(DirectorshipID),
	-- Unique index to Directorship over PresenceConstraint over (Director, Company in "Person directs Company") occurs at most one time
	UNIQUE NONCLUSTERED(DirectorPersonID, CompanyID),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID)
);


CREATE TABLE Employee (
	-- Employee ID
	EmployeeID                              BIGINT IDENTITY NOT NULL,
	-- Employee has Employee Nr
	EmployeeNr                              INTEGER NOT NULL,
	-- Company ID
	CompanyID                               BIGINT IDENTITY NOT NULL,
	-- Employee ID
	ManagerEmployeeID                       BIGINT IDENTITY NOT NULL,
	-- Is Ceo
	ManagerIsCeo                            BOOLEAN,
	-- Primary index to Employee
	PRIMARY KEY CLUSTERED(EmployeeID),
	-- Unique index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
	UNIQUE NONCLUSTERED(EmployeeNr),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID),
	FOREIGN KEY (ManagerEmployeeID) REFERENCES Employee (EmployeeID)
);


CREATE TABLE Employment (
	-- Person ID
	PersonID                                BIGINT IDENTITY NOT NULL,
	-- Employee ID
	EmployeeID                              BIGINT IDENTITY NOT NULL,
	-- Primary index to Employment over PresenceConstraint over (Person, Employee in "Person works as Employee") occurs at most one time
	PRIMARY KEY CLUSTERED(PersonID, EmployeeID),
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);


CREATE TABLE Meeting (
	-- Meeting ID
	MeetingID                               BIGINT IDENTITY NOT NULL,
	-- Company ID
	CompanyID                               BIGINT IDENTITY NOT NULL,
	-- Meeting is held on Date
	[Date]                                  DATE NOT NULL,
	-- Is Board Meeting
	IsBoardMeeting                          BOOLEAN,
	-- Primary index to Meeting
	PRIMARY KEY CLUSTERED(MeetingID),
	-- Unique index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	UNIQUE NONCLUSTERED(CompanyID, [Date], IsBoardMeeting),
	FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID)
);


CREATE TABLE Person (
	-- Person ID
	PersonID                                BIGINT IDENTITY NOT NULL,
	-- Person has given-Name
	GivenName                               VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	FamilyName                              VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	BirthDate                               DATE NULL CHECK(BirthDate >= '1900/01/01'),
	-- Primary index to Person
	PRIMARY KEY CLUSTERED(PersonID)
);

CREATE UNIQUE NONCLUSTERED INDEX PersonByGivenNameFamilyName ON Person(GivenName, FamilyName) WHERE FamilyName IS NOT NULL;


ALTER TABLE Attendance
	ADD FOREIGN KEY (AttendeePersonID) REFERENCES Person (PersonID);


ALTER TABLE Attendance
	ADD FOREIGN KEY (MeetingID) REFERENCES Meeting (MeetingID);


ALTER TABLE Directorship
	ADD FOREIGN KEY (DirectorPersonID) REFERENCES Person (PersonID);


ALTER TABLE Employment
	ADD FOREIGN KEY (PersonID) REFERENCES Person (PersonID);

