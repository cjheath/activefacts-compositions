CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE attendance (
	-- Attendance involves Attendee and Person has given-Name
	attendee_given_name                     VARCHAR(48) NOT NULL,
	-- Attendance involves Attendee and maybe Person is called family-Name
	attendee_family_name                    VARCHAR(48) NULL,
	-- Attendance involves Meeting that is held by Company that is called Company Name
	meeting_company_name                    VARCHAR(48) NOT NULL,
	-- Attendance involves Meeting that is held on Date
	meeting_date                            DATE NOT NULL,
	-- Attendance involves Meeting that Is Board Meeting
	meeting_is_board_meeting                BOOLEAN,
	-- Primary index to Attendance(Attendee, Meeting in "Person attended Meeting")
	UNIQUE(attendee_given_name, attendee_family_name, meeting_company_name, meeting_date, meeting_is_board_meeting)
);


CREATE TABLE company (
	-- Company is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- Company Is Listed
	is_listed                               BOOLEAN,
	-- Primary index to Company(Company Name in "Company is called Company Name")
	PRIMARY KEY(company_name)
);


CREATE TABLE directorship (
	-- Directorship involves Director and Person has given-Name
	director_given_name                     VARCHAR(48) NOT NULL,
	-- Directorship involves Director and maybe Person is called family-Name
	director_family_name                    VARCHAR(48) NULL,
	-- Directorship involves Company that is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- Directorship began on appointment-Date
	appointment_date                        DATE NOT NULL,
	-- Primary index to Directorship(Director, Company in "Person directs Company")
	UNIQUE(director_given_name, director_family_name, company_name),
	FOREIGN KEY (company_name) REFERENCES company (company_name)
);


CREATE TABLE employee (
	-- Employee has Employee Nr
	employee_nr                             INTEGER NOT NULL,
	-- Employee works at Company that is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee that has Employee Nr
	manager_nr                              INTEGER NULL,
	-- maybe Employee is a Manager that Is Ceo
	manager_is_ceo                          BOOLEAN,
	-- Primary index to Employee(Employee Nr in "Employee has Employee Nr")
	PRIMARY KEY(employee_nr),
	FOREIGN KEY (company_name) REFERENCES company (company_name),
	FOREIGN KEY (manager_nr) REFERENCES employee (employee_nr)
);


CREATE TABLE employment (
	-- Employment involves Person that has given-Name
	person_given_name                       VARCHAR(48) NOT NULL,
	-- Employment involves Person that maybe is called family-Name
	person_family_name                      VARCHAR(48) NULL,
	-- Employment involves Employee that has Employee Nr
	employee_nr                             INTEGER NOT NULL,
	-- Primary index to Employment(Person, Employee in "Person works as Employee")
	UNIQUE(person_given_name, person_family_name, employee_nr),
	FOREIGN KEY (employee_nr) REFERENCES employee (employee_nr)
);


CREATE TABLE meeting (
	-- Meeting is held by Company that is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- Meeting is held on Date
	"date"                                  DATE NOT NULL,
	-- Is Board Meeting
	is_board_meeting                        BOOLEAN,
	-- Primary index to Meeting(Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting")
	PRIMARY KEY(company_name, "date", is_board_meeting),
	FOREIGN KEY (company_name) REFERENCES company (company_name)
);


CREATE TABLE person (
	-- Person has given-Name
	given_name                              VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	family_name                             VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	birth_date                              DATE NULL CHECK(birth_date >= '1900/01/01'),
	-- Primary index to Person(Given Name, Family Name in "Person has given-Name", "family-Name is of Person")
	UNIQUE(given_name, family_name)
);


ALTER TABLE attendance
	ADD FOREIGN KEY (attendee_given_name, attendee_family_name) REFERENCES person (given_name, family_name);

ALTER TABLE attendance
	ADD FOREIGN KEY (meeting_company_name, meeting_date, meeting_is_board_meeting) REFERENCES meeting (company_name, "date", is_board_meeting);

ALTER TABLE directorship
	ADD FOREIGN KEY (director_given_name, director_family_name) REFERENCES person (given_name, family_name);

ALTER TABLE employment
	ADD FOREIGN KEY (person_given_name, person_family_name) REFERENCES person (given_name, family_name);
