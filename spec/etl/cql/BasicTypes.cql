/*
 * Basic Types:
 */
topic BasicTypes version 1.0.0;

/* Identity types */
each SID is written as GUID auto-assigned at assert;
each ID is written as an Auto Counter;

/* Integer types */
each Count is written as Integer;
each Ordinal is written as Integer restricted to {0..};
each File Size is written as Integer restricted to {0..};

/* Temporal data types */
each Date is written as Date;
each Time is written as Time;
each Date Time is written as Date Time;

/* Various string data types */
each Date is written as a Date;
each Phone Number is written as a String;
informally, each Phone Number is standardised to international format (e.g. +61-401-234-567).

each EmailAddress is written as String(80);
each IP Address is written as inet;
each Value String is written as String(1024);
each Description is written as String(1024);

each SHA256 is written as Char(64);
each URL is written as String(1024);
each Comment is written as String(4000);

/* Search configuration for Strings */
each String is written as a String(
    accepts Search as String restricted to {
	'none',		// Do not index this value
	'simple',	// Disregard white-space only
	'alpha',	// Strip white space and punctuation, just use alphabetic characters
	'phonetic',	// Use phonetic matching and trigrams as well as alpha
	'words',	// Break the text into words and match each word like alpha
	'names',	// Break the text into words and match each word like phonetic
	// 'text'	// Index a large text field using significant words and phrases

	'number',	// Strip numeric separators and sequence numerically
	'phone',	// Search using phone number rules (reverse trailing digits?), maybe multiple numbers
	'email',	// Search using email rules, maybe multiple email addresses
	'date'		// Handle date proximity matching
    });
