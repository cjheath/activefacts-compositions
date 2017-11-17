CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE attendance (
	-- Attendance involves Attendee
	attendee_person_id                      BIGINT NOT NULL,
	-- Attendance involves Meeting
	meeting_id                              BIGINT NOT NULL,
	-- Primary index to Attendance over PresenceConstraint over (Attendee, Meeting in "Person attended Meeting") occurs at most one time
	PRIMARY KEY(attendee_person_id, meeting_id)
);


CREATE TABLE company (
	-- Company surrogate key
	company_id                              BIGSERIAL NOT NULL,
	-- Company is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- Company Is Listed
	is_listed                               BOOLEAN,
	-- Primary index to Company
	PRIMARY KEY(company_id),
	-- Unique index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
	UNIQUE(company_name)
);


CREATE TABLE directorship (
	-- Directorship surrogate key
	directorship_id                         BIGSERIAL NOT NULL,
	-- Directorship involves Director
	director_person_id                      BIGINT NOT NULL,
	-- Directorship involves Company
	company_id                              BIGINT NOT NULL,
	-- Directorship began on appointment-Date
	appointment_date                        DATE NOT NULL,
	-- Primary index to Directorship
	PRIMARY KEY(directorship_id),
	-- Unique index to Directorship over PresenceConstraint over (Director, Company in "Person directs Company") occurs at most one time
	UNIQUE(director_person_id, company_id),
	FOREIGN KEY (company_id) REFERENCES company (company_id)
);


CREATE TABLE employee (
	-- Employee surrogate key
	employee_id                             BIGSERIAL NOT NULL,
	-- Employee has Employee Nr
	employee_nr                             INTEGER NOT NULL,
	-- Employee works at Company
	company_id                              BIGINT NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee
	manager_employee_id                     BIGINT NULL,
	-- maybe Employee is a Manager that Is Ceo
	manager_is_ceo                          BOOLEAN,
	-- Primary index to Employee
	PRIMARY KEY(employee_id),
	-- Unique index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
	UNIQUE(employee_nr),
	FOREIGN KEY (company_id) REFERENCES company (company_id),
	FOREIGN KEY (manager_employee_id) REFERENCES employee (employee_id)
);


CREATE TABLE employment (
	-- Employment involves Person
	person_id                               BIGINT NOT NULL,
	-- Employment involves Employee
	employee_id                             BIGINT NOT NULL,
	-- Primary index to Employment over PresenceConstraint over (Person, Employee in "Person works as Employee") occurs at most one time
	PRIMARY KEY(person_id, employee_id),
	FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);


CREATE TABLE meeting (
	-- Meeting surrogate key
	meeting_id                              BIGSERIAL NOT NULL,
	-- Meeting is held by Company
	company_id                              BIGINT NOT NULL,
	-- Meeting is held on Date
	"date"                                  DATE NOT NULL,
	-- Is Board Meeting
	is_board_meeting                        BOOLEAN,
	-- Primary index to Meeting
	PRIMARY KEY(meeting_id),
	-- Unique index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	UNIQUE(company_id, "date", is_board_meeting),
	FOREIGN KEY (company_id) REFERENCES company (company_id)
);


CREATE TABLE person (
	-- Person surrogate key
	person_id                               BIGSERIAL NOT NULL,
	-- Person has given-Name
	given_name                              VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	family_name                             VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	birth_date                              DATE NULL CHECK(birth_date >= '1900/01/01'),
	-- Primary index to Person
	PRIMARY KEY(person_id),
	-- Unique index to Person over PresenceConstraint over (Given Name, Family Name in "Person has given-Name", "family-Name is of Person") occurs at most one time
	UNIQUE(given_name, family_name)
);


ALTER TABLE attendance
	ADD FOREIGN KEY (attendee_person_id) REFERENCES person (person_id);


ALTER TABLE attendance
	ADD FOREIGN KEY (meeting_id) REFERENCES meeting (meeting_id);


ALTER TABLE directorship
	ADD FOREIGN KEY (director_person_id) REFERENCES person (person_id);


ALTER TABLE employment
	ADD FOREIGN KEY (person_id) REFERENCES person (person_id);

