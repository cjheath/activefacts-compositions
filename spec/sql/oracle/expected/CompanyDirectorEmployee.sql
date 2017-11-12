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
	MEETING_IS_BOARD_MEETING                BOOLEAN
);

CREATE UNIQUE INDEX ATTENDANCEByATTENDEE_GIVEN_NAMEATTENDEE_FAMILY_NAMEMEET1cebe ON ATTENDANCE(ATTENDEE_GIVEN_NAME, ATTENDEE_FAMILY_NAME, MEETING_COMPANY_NAME, MEETING_DATE, MEETING_IS_BOARD_MEETING) WHERE ATTENDEE_FAMILY_NAME IS NOT NULL;


CREATE TABLE COMPANY (
	-- Company is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- Company Is Listed
	IS_LISTED                               BOOLEAN,
	-- Primary index to Company over PresenceConstraint over (Company Name in "Company is called Company Name") occurs at most one time
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
	FOREIGN KEY (COMPANY_NAME) REFERENCES COMPANY (COMPANY_NAME)
);

CREATE UNIQUE INDEX DIRECTORSHIPByDIRECTOR_GIVEN_NAMEDIRECTOR_FAMILY_NAMECOMPANY ON DIRECTORSHIP(DIRECTOR_GIVEN_NAME, DIRECTOR_FAMILY_NAME, COMPANY_NAME) WHERE DIRECTOR_FAMILY_NAME IS NOT NULL;


CREATE TABLE EMPLOYEE (
	-- Employee has Employee Nr
	EMPLOYEE_NR                             INTEGER NOT NULL,
	-- Employee works at Company that is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- maybe Employee is supervised by Manager that is a kind of Employee that has Employee Nr
	MANAGER_NR                              INTEGER NULL,
	-- maybe Employee is a Manager that Is Ceo
	MANAGER_IS_CEO                          BOOLEAN,
	-- Primary index to Employee over PresenceConstraint over (Employee Nr in "Employee has Employee Nr") occurs at most one time
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
	FOREIGN KEY (EMPLOYEE_NR) REFERENCES EMPLOYEE (EMPLOYEE_NR)
);

CREATE UNIQUE INDEX EMPLOYMENTByPERSON_GIVEN_NAMEPERSON_FAMILY_NAMEEMPLOYEE_NR ON EMPLOYMENT(PERSON_GIVEN_NAME, PERSON_FAMILY_NAME, EMPLOYEE_NR) WHERE PERSON_FAMILY_NAME IS NOT NULL;


CREATE TABLE MEETING (
	-- Meeting is held by Company that is called Company Name
	COMPANY_NAME                            VARCHAR(48) NOT NULL,
	-- Meeting is held on Date
	"DATE"                                  DATE NOT NULL,
	-- Is Board Meeting
	IS_BOARD_MEETING                        BOOLEAN,
	-- Primary index to Meeting over PresenceConstraint over (Company, Date, Is Board Meeting in "Meeting is held by Company", "Meeting is held on Date", "Meeting is board meeting") occurs at most one time
	PRIMARY KEY(COMPANY_NAME, "DATE", IS_BOARD_MEETING),
	FOREIGN KEY (COMPANY_NAME) REFERENCES COMPANY (COMPANY_NAME)
);


CREATE TABLE PERSON (
	-- Person has given-Name
	GIVEN_NAME                              VARCHAR(48) NOT NULL,
	-- maybe Person is called family-Name
	FAMILY_NAME                             VARCHAR(48) NULL,
	-- maybe Person was born on birth-Date
	BIRTH_DATE                              DATE NULL CHECK(BIRTH_DATE >= '1900/01/01')
);

CREATE UNIQUE INDEX PERSONByGIVEN_NAMEFAMILY_NAME ON PERSON(GIVEN_NAME, FAMILY_NAME) WHERE FAMILY_NAME IS NOT NULL;


ALTER TABLE ATTENDANCE
	ADD FOREIGN KEY (ATTENDEE_GIVEN_NAME, ATTENDEE_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);


ALTER TABLE ATTENDANCE
	ADD FOREIGN KEY (MEETING_COMPANY_NAME, MEETING_DATE, MEETING_IS_BOARD_MEETING) REFERENCES MEETING (COMPANY_NAME, "DATE", IS_BOARD_MEETING);


ALTER TABLE DIRECTORSHIP
	ADD FOREIGN KEY (DIRECTOR_GIVEN_NAME, DIRECTOR_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);


ALTER TABLE EMPLOYMENT
	ADD FOREIGN KEY (PERSON_GIVEN_NAME, PERSON_FAMILY_NAME) REFERENCES PERSON (GIVEN_NAME, FAMILY_NAME);

