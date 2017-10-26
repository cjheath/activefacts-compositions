vocabulary Corporate;

/*
 * Value Types
 */
String is written as String;
ABN is written as String(11);
ACN is written as String(9);
Amount is written as Money;
ID is written as Auto Counter;
Apprenticeship Application ID is written as ID;
Aptitude Test Name is written as String(60);
Aptitude Test Result Code is written as String(16);
Authentication Type Name is written as String(60);
Authentication Value is written as String(80);
Candidate Status [independent] is written as String;
Code is written as String(16);
Comment is written as String(4000);
Company Name is written as String(60);
Confirmation Token is written as String;
Contact Kind is written as String(32);
Contact Method Name is written as String;
Time Division is written as String restricted to {'day', 'fortnight', 'hour', 'minute', 'month', 'second', 'week', 'year'};
Contact Period is written as Time Division restricted to {'day', 'month', 'week'};
Contact Schedule Name is written as String;
Contact Type Name is written as String;
Correspondence Method Name is written as String(60);
Name is written as String(60);
Correspondence Template Name is written as Name;
Count is written as Unsigned Integer(32);
Country Name is written as String(60);
Data Type Name is written as String;
Data Value Restriction is written as String;
Date is written as Date;
Date Time is written as Date Time;
Demerit Points is written as Signed Integer(16) restricted to {0..20};
Department Name is written as String;
Digitised Signature is written as String(1024);
Document Format Code is written as String(16);
Document ID is written as ID;
EmailAddress is written as String(80);
Encrypted Password is written as String;
File Note ID is written as ID;
File Note Template Name is written as String;
File Note Type [independent] is written as String;
Gender Code is written as String(16);
IP Address is written as String(32);
ISO3166Code2 is written as String(2);
ISO3166Code3 is written as String(3);
ISO3166Numeric3 is written as Signed Integer(32);
Interview Type is written as String(60);
Job Description is written as Comment;
Job Title Name is written as String(60);
Language Name is written as String(60);
Site ID is written as ID;
Site Usage [independent] is written as String(32);
Month Nr is written as Signed Integer(32);
Nr is written as Signed Integer(32);
Party ID is written as ID;
Party Type Code is written as String(16);
PayrollNr is written as String(20);
Personal Characteristic Name is written as String(60);
Phone Number is written as String(32);
Phone Role [independent] is written as String(20);
Photo ID is written as ID;
Placement Application ID is written as ID;
Placement Application Result Code is written as String(16);
Placement Result Code is written as String(16);
Placement Type Code is written as String(16);
Postcode is written as String(12);
Preference Value is written as String;
Public Liability Cover ID is written as ID;
Questionnaire Name is written as String;
Referral Name is written as String(60);
Relationship Code is written as String(16);
Reset Password Token is written as String;
Resource ID is written as ID;
Resource Type is written as String(60);
Salutation Code is written as String(16);
School Name is written as String(60);
School Yr Level Nr is written as Signed Integer(32);
Search Facet Name is written as String;
Search Facet Value is written as String;
Search ID is written as ID;
Search Title is written as String(60);
Settable Preference Name is written as String;
Skills Certification Name is written as String(60);
State Code is written as String(3);
State Name is written as String(60);
Street is written as String(64);
Subject Results Summary is written as String(120);
Suburb Name is written as String(60);
Time is written as Time;
Time Basis [independent] is written as String;
Travel Method Code is written as String(16);
URL is written as String(512);
Vacancy ID is written as ID;
Vacancy Status Code is written as String(16);
Vehicle Description is written as String(32);
Vehicle Licence Number is written as String(24);
Vehicle Licence Type Name is written as String(60);
Vehicle User Role is written as String(20) restricted to {'owner', 'user'};
Widget Name is written as String;
Widget Path is written as String;
Widget Title is written as String;
Work Status [independent] is written as String;
Year Nr is written as Nr(32);

/*
 * Entity Types
 */
Aptitude Test [static] is independent identified by its Name;

Aptitude Test Result is identified by its Code;

Authentication Type [static] is independent identified by its Name;
Authentication Type is sensitive;

Contact Interval is where
	contact is due after Count Contact Period;

Contact Method [static] is independent identified by its Name;

Contact Schedule [static] is independent identified by its Name;

Contact Type [static] is independent identified by its Name;

Correspondence Method [static] is independent identified by its Name;

Correspondence Template is identified by its Name;

Country [static] is identified by ISO3166Code3 where
	Country has one ISO3166Code3,
	ISO3166Code3 is of at most one Country;
Country is called one Country Name,
	Country Name is of at most one Country;
Country has one ISO3166Code2,
	ISO3166Code2 is of one Country;
Country has one ISO3166Numeric3,
	ISO3166Numeric3 is of one Country;

Data Type [static] is identified by its Name;

DateMaybeTime is identified by Date and Time where
	DateMaybeTime has one Date,
	DateMaybeTime has at most one Time;

Document is identified by its ID;
Document was recorded on at most one Date;
Document is stored in at most one URL,
	URL contains at most one Document;
Document is scanned;

Document Format [static] is independent identified by its Code;
Document is in one Document Format,
	Document Format is of Document;

File Note is identified by its ID;
File Note was created on one created-Date;
File Note contains one Comment;
File Note is of one File Note Type;
File Note has at most one attached-Document;
File Note was followed up on at most one completion-Date;
File Note requires followup by at most one followup-Date;

File Note Template [static] is independent identified by its Name;
File Note is created from at most one File Note Template;
File Note Template contains at most one Comment;
File Note Template has at most one followup- days Count;
File Note Template has at most one type-Name;
File Note Template is published;

Gender [static] is independent identified by its Code;
Gender has one gender-Name;

Job Title is identified by its Name;

Language [static] is independent identified by its Name;

Month is identified by its Nr restricted to {1..12};

Party is identified by its ID;

Party Authentication is where
	Party has Authentication Type of one Authentication Value,
	Party has Authentication Value for secondary-Authentication Type,
	Authentication Type of Party is Authentication Value;

Party Phone is where
	Party has Phone Role phone on one Phone Number,
	Phone Role phone of Party uses Phone Number;
Party Phone can receive fax;
Party Phone can receive sms;

Party Type is identified by its Code restricted to {'Company', 'Person'};
Party is of one Party Type;

Person is a kind of Party [separate];
Document was recorded by at most one Person;
Person uses at most one EmailAddress,
	EmailAddress is used by Person;
Person has File Note,
	File Note applies to at most one Person;
Person is of at most one Gender;
Person was born on at most one birth-Date;
Person has at most one family-Name,
	family-Name is of Person;
Person is called given-Name;  // Avoid ambiguity; this is a new fact type
Person is called one given-Name,
	given-Name is of Person;
Person has middle-Name;  // Avoid ambiguity; this is a new fact type
Person has at most one middle-Name,
	middle-Name is of Person;
Person prefers preferred-Name;  // Avoid ambiguity; this is a new fact type
Person prefers at most one preferred-Name,
	preferred-Name is of Person;

Personal Characteristic [static] is independent identified by its Name;

Personal Emergency Contact is identified by Person and Contact Name where
	Personal Emergency Contact is for one Person,
	Personal Emergency Contact has one Name (as Contact Name);
Personal Emergency Contact has one Phone Number;

Photo is identified by its ID;
Person has at most one Photo,
	Photo is of Person;

Placement Application Result is identified by its Code;

Placement Result is identified by its Code;

Placement Type is identified by its Code;

Previous Employer is identified by Company Name where
	Previous Employer has one Company Name,
	Company Name is of at most one Previous Employer;

Questionnaire is identified by its Name;

Questionnaire Section is identified by Questionnaire and section-Nr where
	Questionnaire Section belongs to one Questionnaire,
	Questionnaire has Questionnaire Section,
	Questionnaire Section has one section-Nr,
	section-Nr is of Questionnaire Section;
Questionnaire Section has one section-Name;

Referral is independent identified by its Name;

Relationship is identified by its Code;
Personal Emergency Contact has at most one Relationship;

Resource is identified by its ID;

Salutation [static] is independent identified by its Code;
Person is addressed by at most one Salutation,
	Salutation applies to Person;

Scheduled Contact is where
	Contact Schedule requires contact after Contact Interval;
Scheduled Contact has at most one Contact Method;
Scheduled Contact is of at most one Contact Type;
Scheduled Contact uses at most one Questionnaire;
Scheduled Contact repeats on at most one repeat-Contact Interval;
Scheduled Contact is apprenticeship completion check;

School is identified by its Name;

School Yr Level is identified by its Nr;

Search is identified by its ID;
Search has one Search Title;
Search is public;

Search Facet [static] is identified by its Name;

Settable Preference [static] is identified by its Name;
Settable Preference is of one Data Type;
Settable Preference is restricted by at most one Data Value Restriction;

Skills Certification [static] is independent identified by its Name;
Skills Certification has at most one certificate-Code;

State [static] is identified by Country and State Code where
	State is in one Country, Country includes State,
	State has one State Code, State Code is of State;
State has one State Name,
	State Name is of at most one State;

Suburb [static] is identified by State and Suburb Name and Postcode where
	Suburb is in one State, State includes Suburb,
	Suburb has one Suburb Name, Suburb Name is of Suburb,
	Suburb has one Postcode, Postcode is of Suburb;

Travel Method [static] is independent identified by its Code;

User is a kind of Person [separate];

User Role [static] is identified by Name where
	User Role has one Name,
	Name is of at most one User Role;
User Role was created at one Date Time (as Created At);
User Role was updated at at most one Date Time (as Updated At);
User Role covers at most one Resource;
User Role covers at most one Resource Type;
Authorization is where
	User is authorized to act in User Role;

File Note follow-up was completed by at most one completed- by User;
File Note requires followup by at most one followup-User;
File Note Template has at most one followup-User;
User has at most one Confirmation Token;
User is currently signed in at at most one Date Time (as Current Sign In At);
User is remembered since at most one Date Time (as Remember Created At);
User previously signed in at at most one Date Time (as Last Sign In At);
User was confirmed at at most one Date Time (as Confirmed At);
User was sent confirmation request at at most one Date Time (as Confirmation Sent At);
User was sent password recovery token at at most one Date Time (as Reset Password Sent At);
User has one EmailAddress (as Email),
	Email is of at most one User;
User has one Encrypted Password,
	Encrypted Password is of User;
User is currently signed in from at most one IP Address (as Current Sign In IP);
User previously signed in from at most one IP Address (as Last Sign In IP);
User has at most one Reset Password Token,
	Reset Password Token was sent to at most one User;
User saved Search,
	Search was saved by one User;
User has one sign-- in Count;
User (as Unconfirmed User) has unconfirmed-EmailAddress (as Unconfirmed Email);  // Avoid ambiguity; this is a new fact type
User (as Unconfirmed User) has at most one unconfirmed-EmailAddress (as Unconfirmed Email),
	Unconfirmed Email of at most one Unconfirmed User is unconfirmed;

Vehicle Licence Type [static] is independent identified by its Name;

Widget [static] is identified by its Name;
Widget has at most one Widget Path (as Partial Path);
Widget has at most one Widget Title;

Worker is a kind of Person [separate];
Worker has one Work Status;

Year is identified by its Nr restricted to {1900..};

YearMaybeMonth is identified by Year and Month where
	YearMaybeMonth was in one Year,
	YearMaybeMonth was in at most one Month;

Address is identified by Suburb and Street where
	Address has one Street,	// Including number
	Address has one Suburb;

Candidate is a kind of Person [separate];
Candidate has at most one Candidate Status;
Candidate has completed at most one School Yr Level (as Highest Completed School Yr Level);
Candidate completed school in at most one Year (as Final Year At School);
Candidate was born in at most one birth-Country;
immigrant- Candidate has at most one primary- citizenship Country;
Candidate has at most one resume-Document;
Candidate had status update on at most one status- update Date;
Candidate achieved at most one year10-Subject Results Summary;
Candidate achieved at most one year11-Subject Results Summary;
Candidate achieved at most one year12-Subject Results Summary;
Candidate is prepared to re-locate;

Candidate Referral is where
	Candidate received Referral;

Company is a kind of Party [separate];
Company has one ABN,
	ABN is of at most one Company;
Company has at most one ACN,
	ACN is of at most one Company;
Company (as Legal Company) has one legal-Company Name,
	legal-Company Name is of at most one Legal Company;
Company uses trading-Company Name;  // Avoid ambiguity; this is a new fact type
Company uses at most one trading-Company Name,
	trading-Company Name is of at most one Company;
Company has at most one website-URL,
	website-URL is of Company;

Department is identified by Company and Department Name where
	Department is called one Department Name,
	Department Name is of Department,
	Department is part of one Company,
	Company has Department;
Department belongs to at most one parent-Department [acyclic, transitive],
	parent-Department contains Department;

Contact is where
	Party requires contact on due-Date;
Contact has one Contact Method;
Contact has one Contact Type;
Contact was carried out on at most one Date Time;
Contact was carried out by at most one Person (as Contacter);
Contact uses at most one Questionnaire,
	Questionnaire is used by Contact;
Contact was derived from at most one Scheduled Contact;
Contact is booked at at most one actual-Date Time;
Contact is booked for one booked- for Person;
Contact is cancelled;
Contact is suspended;

Contact Report is identified by Contact where
	Contact Report is for one Contact,
	Contact has at most one Contact Report;
Contact Report required follow-up at most one File Note;
Contact Report was lodged by at most one completedby-User;
Contact Report has at most one overall-Comment;

Contact Role is where
	Person is Contact Kind contact for Department,
	Contact Kind contact for Department is Person;
Contact Role is primary;

Contact Signature is where
	Contact Report has Digitised Signature for Contact Kind;
Contact Signature was applied on one Date;
Contact Signature was applied on behalf of at most one Party (as On Behalf Of);
Contact Signature was applied by one Person;

Conviction is where
	Candidate has conviction;
File Note applies to at most one Conviction,
	Conviction has at least one File Note;

Correspondence is where
	Party was in contact on DateMaybeTime by Correspondence Method,
	Party was in contact by Correspondence Method on DateMaybeTime;
Correspondence attracted at most one Comment;
Correspondence concerned at most one Contact;
Correspondence was generated using at most one Correspondence Template;
Correspondence was handled by at most one Person (as Staff Member);
follow-up to Correspondence is complete;
Correspondence requires follow-up by at most one follow-- up Date;
Correspondence has at most one purpose-Name;
Correspondence has at most one received-Document;
Correspondence has at most one sent-Document;

Dashboard is identified by User where
	Dashboard belongs to one User,
	User has one Dashboard;

Dashboard Widget is where
	Dashboard contains Widget;
Dashboard Widget was created at one Date Time (as Created At);
Dashboard Widget was updated at one Date Time (as Updated At);
Dashboard Widget has one weight-Nr;
Dashboard Widget is active;

Driver is a kind of Person;
Driver drives at most one Vehicle Description;
Driver is at most one Vehicle User Role of private vehicle;

Employer is a kind of Company;

Vacancy is identified by its ID;
Vacancy is for one Count -apprentices;
Vacancy has at most one Time Basis;
Vacancy is for one Job Title;
Employer has Vacancy,
	Vacancy is with one Employer;
Vacancy has at most one Contact Role;

Vacancy is described by at most one Job Description;
Vacancy applications close on at most one [satellite availability] Date (as Application Closing Date);
Vacancy must be filled by at most one [satellite availability] Date (as Fill By Date);
Vacancy closes on at most one [satellite availability] closing-Date;
Vacancy starts on at most one [satellite availability] opening-Date;
Vacancy has File Note,
	File Note applies to at most one Vacancy;
Vacancy is for apprentice;
Vacancy is for trainee;
either Vacancy is for trainee or Vacancy is for apprentice but not both;
Vacancy Status is identified by its Code;
Vacancy has one Vacancy Status;

Employment is where
	Person (as Employee) works for Employer,
	Employer employs Employee;
Employment confers at most one Job Title;
Employment is under at most one PayrollNr;
Employment is as trainee;

Search Filter is where
	Search has Search Facet Value for Search Facet,
	Search for Search Facet has one Search Facet Value;

Interview is where
	Candidate participated in interview with Employer on DateMaybeTime;
File Note applies to at most one Interview,
	Interview has File Note;
Interview is of at most one Interview Type;
Interview was recorded by one Person;

Language Spoken is where
	Candidate speaks Language;

Site is where
	Party has Site Usage at Address;
Employment is at at most one work-Site;
Site has at most one short-Name;
Vacancy is at at most one Site;

Medical Examination is where
	Candidate underwent medical examination;
File Note applies to at most one Medical Examination,
	Medical Examination has at least one File Note;

User Preference is where
	User sets Settable Preference to one Preference Value;

Personal Characterisation is where
	Candidate has Personal Characteristic;

Personal Reference is identified by Candidate and Previous Employer and referee-Name where
	Candidate has Personal Reference,
	Personal Reference is for one Candidate,
	Personal Reference is from at most one Previous Employer,
	Personal Reference is by one referee-Name;
Personal Reference is for at most one Job Title;
Personal Reference has at most one contact-Phone Number;

Placement is where
	Worker fills Vacancy,
	Vacancy is filled by Worker;
Contact Report was made during at most one Placement;
Placement ended in at most one Placement Result;
Placement is of at most one Placement Type;
Placement commences on at most one commencement-Date;
Placement is complete on at most one completion-Date;
Placement nominally ends on at most one nominal- end Date;
Placement issued tools on at most one tool- issue Date;
Placement tools were returned on at most one tool- return Date;

Placement Application is where
	Person applied for Vacancy on one application-Date;
File Note applies to at most one Placement Application,
	Placement Application has File Note;
Interview is for at most one Placement Application,
	Placement Application results in Interview;
Placement Application resulted from referral on at most one Date;
Placement Application was updated on at most one Date (as Last Updated Date);
Placement Application was created by at most one Person (as Creator);
Placement Application was updated by at most one Person (as Updater);
Placement Application yielded at most one Placement Application Result;

Previous Employment is where
	Candidate was employed with Previous Employer;
Previous Employment has File Note,
	File Note applies to at most one Previous Employment;
Previous Employment was under at most one Job Title;
Previous Employment was from at most one YearMaybeMonth (as Employment Start);
Previous Employment was until at most one YearMaybeMonth (as Employment End);

Question is identified by Questionnaire Section and sequence-Nr where
	Question belongs to one Questionnaire Section,
	Question has one sequence-Nr;
Question has one question-String;

Reference Check is identified by Personal Reference where
	Reference Check checked one Personal Reference,
	Personal Reference was checked in at most one Reference Check;
File Note applies to at most one Reference Check,
	Reference Check has File Note;
Reference Check was made on one Date;
Reference Check was made by one Person;
Reference Check confirmed employment from at most one commencement-Date;
Reference Check confirmed employment until at most one completion-Date;
Reference Check was with at most one respondent-Name;

School Achievement is identified by Candidate where
	Candidate has at most one School Achievement,
	School Achievement is of one Candidate;
File Note applies to at most one School Achievement,
	School Achievement has File Note;

School Attendance is where
	Candidate is attending secondary school;
School Attendance is at at most one School;
School Attendance is in at most one Suburb;
School Attendance is at at most one current-School Yr Level;

Skills Certificate is where
	Candidate has Skills Certification;

Superannuation Company is a kind of Company;

Vehicle Licence is where
	Driver has licence of at least one Vehicle Licence Type;
Vehicle Licence has at most one Vehicle Licence Number;
Vehicle Licence was obtained on at most one obtained-Date;
Vehicle Licence has at most one remaining-Demerit Points;
Vehicle Licence is limited to automatic vehicles;

Work Experience is where
	Candidate participated in work experience;
Work Experience was with at most one Company;
Work Experience has at most one contact-Person;

Candidate Travel Method is where
	Candidate commutes by Travel Method,
	Travel Method is used by Candidate;

Allowed Response [static] is where
	Question has allowed- response String;
Allowed Response requires follow-up by user acting in at most one User Role;
Allowed Response has one sequence-Nr;

Aptitude Testing is where
	Candidate participates in Aptitude Test;
Aptitude Testing yielded at most one Aptitude Test Result;
Aptitude Testing is booked on one Date;
Aptitude Testing is booked at at most one Time;
File Note applies to at most one Aptitude Testing,
	Aptitude Testing has File Note;

Contact Response is where
	Contact Report reports Question was discussed;
Contact Response has at most one Comment;

/*
 * Constraints:
 */
for each File Note exactly one of these holds:
	File Note applies to Medical Examination,
	File Note applies to Conviction,
	File Note applies to Aptitude Testing,
	File Note applies to Interview,
	File Note applies to Placement Application,
	File Note applies to School Achievement,
	File Note applies to Reference Check,
	File Note applies to Vacancy,
	File Note applies to Previous Employment;
either Party is a Person or Party is a Company but not both;
for each Company Name at most one of these holds:
	legal-Company Name is of Company,
	trading-Company Name is of Company;
for each Correspondence at most one of these holds:
	Correspondence has sent-Document,
	Correspondence has received-Document;
either Previous Employment was from YearMaybeMonth(1) or Previous Employment was until YearMaybeMonth(2);
