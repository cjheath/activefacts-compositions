CREATE TABLE ATTENDANCE (
	-- Attendance involves Attendee and Person has given-Name
	ATTENDEE_GIVEN_NAME                     VARCHAR(48) NOT NULL,
	-- Attendance involves Attendee and maybe Person is called family-Name
	ATTENDEE_FAMILY_NAME                    VARCHAR(48) NULL,
	-- Attendance involves Meeting that is held by Company that is called Company Name
	MEETING_COMPANY_NAME                    VARCHAR(48) NOT NULL,
	-- Attendance involves Meeting that is held on Date
	MEETING_DATE                            DATE NOT NULL,
	-- Attendance involves Meeting that Is Board Meeting
	MEETING_IS_BOARD_MEETING                CHAR(1),
	-- Primary index to Attendance(Attendee, Meeting in "Person attended Meeting")
	UNIQUE(ATTENDEE_GIVEN_NAME, ATTENDEE_FAMILY_NAME, MEETING_COMPANY_NAME, MEETING_DATE, MEETING_IS_BOARD_MEETING)
);


CREATE TABLE COMPANY (
	-- Company is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- Company Is Listed
	IS_LISTED                               CHAR(1),
	-- Primary index to Company(Company Name in "Company is called Company Name")
	PRIMARY KEY(COMPANY_NAME)
);


CREATE TABLE DIRECTORSHIP (
	-- Directorship involves Director and Person has given-Name
	DIRECTOR_GIVEN_NAME                     VARCHAR(48) NOT NULL,
	-- Directorship involves Director and maybe Person is called family-Name
	DIRECTOR_FAMILY_NAME                    VARCHAR(48) NULL,
	-- Directorship involves Company that is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- Directorship began on appointment-Date
	APPOINTMENT_DATE                        DATE NOT NULL,
	-- Primary index to Directorship(Director, Company in "Person directs Company")
	UNIQUE(DIRECTOR_GIVEN_NAME, DIRECTOR_FAMILY_NAME, COMPANY_NAME),
	FOREIGN KEY (COMPANY_NAME) REFERENCES COMPANY (COMPANY_NAME)
);


CREATE TABLE EMPLOYEE (
	-- Employee has Employee Nr
	EMPLOYEE_NR                             INTEGER NOT NULL,
	-- Employee works at Company that is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee that has Employee Nr
	MANAGER_NR                              INTEGER NULL,
	-- maybe Employee is a Manager that Is Ceo
	MANAGER_IS_CEO                          CHAR(1),
	-- Primary index to Employee(Employee Nr in "Employee has Employee Nr")
	PRIMARY KEY(EMPLOYEE_NR),
	FOREIGN KEY (COMPANY_NAME) REFERENCES COMPANY (COMPANY_NAME),
	FOREIGN KEY (MANAGER_NR) REFERENCES EMPLOYEE (EMPLOYEE_NR)
);


CREATE TABLE EMPLOYMENT (
	-- Employment involves Person that has given-Name
	PERSON_GIVEN_NAME                       VARCHAR(48) NOT NULL,
	-- Employment involves Person that maybe is called family-Name
	PERSON_FAMILY_NAME                      VARCHAR(48) NULL,
	-- Employment involves Employee that has Employee Nr
	EMPLOYEE_NR                             INTEGER NOT NULL,
	-- Primary index to Employment(Person, Employee in "Person works as Employee")
	UNIQUE(PERSON_GIVEN_NAME, PERSON_FAMILY_NAME, EMPLOYEE_NR),
	FOREIGN KEY (EMPLOYEE_NR) REFERENCES EMPLOYEE (EMPLOYEE_NR)
);


CREATE TABLE MEETING (
	-- Meeting is held by Company that is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- Meeting is held on Date
	"DATE"                                  DATE NOT NULL,
	-- Is Board Meeting
	IS_BOARD_MEETING                        CHAR(1),
	-- Primary index to Meeting(Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting")
	PRIMARY KEY(COMPANY_NAME, "DATE", IS_BOARD_MEETING),
	FOREIGN KEY (COMPANY_NAME) REFERENCES COMPANY (COMPANY_NAME)
);


CREATE TABLE PERSON (
	-- Person has given-Name
	GIVEN_NAME                              VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	FAMILY_NAME                             VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	BIRTH_DATE                              DATE NULL CHECK(BIRTH_DATE >= '1900/01/01'),
	-- Primary index to Person(Given Name, Family Name in "Person has given-Name", "family-Name is of Person")
	UNIQUE(GIVEN_NAME, FAMILY_NAME)
);


ALTER TABLE ATTENDANCE
	ADD FOREIGN KEY (ATTENDEE_GIVEN_NAME, ATTENDEE_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);

ALTER TABLE ATTENDANCE
	ADD FOREIGN KEY (MEETING_COMPANY_NAME, MEETING_DATE, MEETING_IS_BOARD_MEETING) REFERENCES MEETING (COMPANY_NAME, "DATE", IS_BOARD_MEETING);

ALTER TABLE DIRECTORSHIP
	ADD FOREIGN KEY (DIRECTOR_GIVEN_NAME, DIRECTOR_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);

ALTER TABLE EMPLOYMENT
	ADD FOREIGN KEY (PERSON_GIVEN_NAME, PERSON_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);
