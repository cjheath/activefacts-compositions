schema Synthetic;

import topic BasicTypes version 1.0;        // Basic types that are widely used

each Agency Person ID is written as a String;
each Person is identified by Agency Person ID;

// Personal names (single and multiple per field)
each Personal Name is written as a String(Search: 'phonetic');
each Personal Names is written as a String(Search: 'names');
each Given Name is written as Personal Names;
each Middle Name is written as a Personal Name;
each Family Name is written as a Personal Name;
each Preferred Name is written as a Personal Name;
each Alias Name is written as a Personal Names;

Person has at most one Given Name;
Person has at most one Family Name;
Person has at most one Preferred Name;
Person uses at most one Alias Name;

// Indigenous status
Person is Aboriginal;
Person is Torres-strait Islander;
Person is indigenous;
// indigenous could be semi-derived from the above two fact types

// Life status
Person was born on at most one birth-Date;
Person is deceased;

// Employer
each Employer Name is written as a String;
each Employer is identified by its Name;
Person has at most one Employer;

// Sex and Gender
each Sex is written as String restricted to {'M', 'F', 'X'};
Person was born as at most one Sex;
each Gender Name is written as a String;
each Gender is identified by Gender Name;
example: Gender 'Female';
example: Gender 'Male';
example: Gender 'Non-binary';
// Any gender we receive will appear here as-received

Person identifies as of at most one Gender;

// We might store more than one phone-number or email address in the same field
each Phone Number is written as a String(Search: 'phone');
Person uses at most one Phone Number;
each EmailAddress is written as String(Search: 'email');
Person uses at most one EmailAddress;

// Some people's identity has special protection:
Person is protected;

// This person is the subject of an alert (violent, weapons, missing person, etc)
Person is subject to alert;

// Locations:
each Agency Location ID is written as a String;
each Location is identified by Agency Location ID;
Location has at most one standardised-Agency Location ID;
each Address Text is written as a String(Search: 'words');
Location has one Address Text;

each Location Purpose is written as a String;	// E.g. 'R' for residential, 'M' for mailing, etc
Related Location is where
    Person uses Location for Location Purpose;
Related Location has at most one start-Date;
Related Location has at most one end-Date;

each Relationship Type is written as a String;
each Related Person is where
    some subject-Person has some Relationship Type to some related-Person;
Related Person has at most one start-Date;
Related Person has at most one end-Date;
