CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE attendance (
	-- Attendance involves Attendee
	attendee_person_id                      BIGINT NOT NULL,
	-- Attendance involves Meeting
	meeting_id                              BIGINT NOT NULL,
	-- Primary index to Attendance(Attendee, Meeting in "Person attended Meeting")
	PRIMARY KEY(attendee_person_id, meeting_id)
);


CREATE TABLE company (
	-- Company surrogate key
	company_id                              BIGSERIAL NOT NULL,
	-- Company is called Company Name
	company_name                            VARCHAR(48) NOT NULL,
	-- Company Is Listed
	is_listed                               BOOLEAN,
	-- Natural index to Company(Company Name in "Company is called Company Name")
	UNIQUE(company_name),
	-- Primary index to Company
	PRIMARY KEY(company_id)
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
	-- Natural index to Directorship(Director, Company in "Person directs Company")
	UNIQUE(director_person_id, company_id),
	-- Primary index to Directorship
	PRIMARY KEY(directorship_id),
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
	-- Natural index to Employee(Employee Nr in "Employee has Employee Nr")
	UNIQUE(employee_nr),
	-- Primary index to Employee
	PRIMARY KEY(employee_id),
	FOREIGN KEY (company_id) REFERENCES company (company_id),
	FOREIGN KEY (manager_employee_id) REFERENCES employee (employee_id)
);


CREATE TABLE employment (
	-- Employment involves Person
	person_id                               BIGINT NOT NULL,
	-- Employment involves Employee
	employee_id                             BIGINT NOT NULL,
	-- Primary index to Employment(Person, Employee in "Person works as Employee")
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
	-- Natural index to Meeting(Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting")
	UNIQUE(company_id, "date", is_board_meeting),
	-- Primary index to Meeting
	PRIMARY KEY(meeting_id),
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
	-- Natural index to Person(Given Name, Family Name in "Person has given-Name", "family-Name is of Person")
	UNIQUE(given_name, family_name),
	-- Primary index to Person
	PRIMARY KEY(person_id)
);


ALTER TABLE attendance
	ADD FOREIGN KEY (attendee_person_id) REFERENCES person (person_id);


ALTER TABLE attendance
	ADD FOREIGN KEY (meeting_id) REFERENCES meeting (meeting_id);


ALTER TABLE directorship
	ADD FOREIGN KEY (director_person_id) REFERENCES person (person_id);


ALTER TABLE employment
	ADD FOREIGN KEY (person_id) REFERENCES person (person_id);

