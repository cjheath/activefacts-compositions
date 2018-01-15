schema GNAF;

// Data types:
each Date Range is written as a DateRange;
each Date is written as a Date;
each String is written as a String(
    accepts Search as String restricted to {
	'none',		// Do not index this value
	'simple',	// Disregard white-space only
	'alpha',	// Strip white space and punctuation, just use alphabetic characters
	'number',	// Strip thousands separators and justify
	'phone',	// Prefix match on reverse digits excluding all non-numerics
	'words',	// Break the text into words and match each word like alpha
	// 'phrases',	// Words, but where adjacent sequences of words matter
	'typo',		// Use trigram similarity to detect typographic errors
	'phonetic',	// Use phonetic matching as well as trigrams
	'names',	// Break the text into words and match each word like phonetic
	'text'		// Index a large text field using significant words and phrases
    });

each Numeric Fragment is written as a Char(
    accepts Search as String restricted to {
	'none',		// Do not index this value
	'simple',	// Disregard white-space only
	'alpha'		// Strip white space and punctuation, just use alphabetic characters
    });

// Widespread value types:
each Postcode is written as a String(4, Search: 'simple');
each Latitude is written as a Decimal(10,8);
each Longitude is written as a Decimal(11,8);
each Confidence is written as a Decimal(1); // N+1 datasets provide this data

// informally, each PID is an opaque identifier for a G-NAF record.
each PID is written as a String(15, Search: 'none');

/*
 * Geocode levels [static]
 */
each Geocoded Level Code is written as a Decimal(2);	// Avoid name overlap with "Level Type"
each Geocoded Level Name is written as a String(50, Search: 'none');
each Geocoded Level Description is written as a Char(100);
each Geocoded Level Type [static] is independent identified by Code where
    Geocoded Level Type has one Geocoded Level Code (as Code);
Geocoded Level Type is called one Geocoded Level Name (as Name);
Geocoded Level Type has one Geocoded Level Description (as Description);
Geocoded Level Type 0;	// No geocode
Geocoded Level Type 1;	// No Locality geocode, No Street geocode, Address geocode
Geocoded Level Type 2;  // No Locality geocode, Street geocode, No Address geocode
Geocoded Level Type 3;  // No Locality geocode, Street geocode, Address geocode
Geocoded Level Type 4;  // Locality geocode, No Street geocode, No Address geocode
Geocoded Level Type 5;  // Locality geocode, No Street geocode, Address geocode
Geocoded Level Type 6;  // Locality geocode, Street geocode, No Address geocode
Geocoded Level Type 7;  // Locality geocode, Street geocode, Address geocode

/*
 * Geocode Reliability [static]
 */
each Geocode Reliability Code is written as a Decimal(1);
each Geocode Reliability Name is written as a String(50);
each Geocode Reliability Description is written as a Char(100);
each Geocode Reliability [static] is independent identified by Code where
    Geocode Reliability has one Geocode Reliability Code (as Code),
    Code is for at most one Geocode Reliability;
Geocode Reliability is called one Geocode Reliability Name (as Name);
Geocode Reliability has one Geocode Reliability Description (as Description);
Geocode Reliability 1 is called Geocode Reliability Name 'Surveying Standard';
Geocode Reliability 2 is called Geocode Reliability Name 'Within Address Site Boundary or Access Point';
Geocode Reliability 3 is called Geocode Reliability Name 'Near (Or Possibly Within) Address Site Boundary';
Geocode Reliability 4 is called Geocode Reliability Name 'Unique Road Feature';
Geocode Reliability 5 is called Geocode Reliability Name 'Unique Locality Or Neighbourhood';
Geocode Reliability 6 is called Geocode Reliability Name 'Unique Region';
each GNAF Reliability is a kind of Geocode Reliability;	// Trick to get column naming to work.

/*
 * Geocode Type [static]
 */
each Geocode Type Code is written as a String(4, Search: 'none');
each Geocode Type Name is written as a String(50);
each Geocode Type Description is written as a Char(250);
each Geocode Type [static] is independent identified by Code where
    Geocode Type has one Geocode Type Code (as Code),
    Code is for at most one Geocode Type;
Geocode Type is called one Geocode Type Name (as Name);
Geocode Type has at most one Geocode Type Description (as Description);
Geocode Type 'BAP' is called Geocode Type Name 'Building access point';
Geocode Type 'BAP' has Geocode Type Description 'Point of access to the building';
Geocode Type 'BC' is called Geocode Type Name 'Building centroid';
Geocode Type 'BC' has Geocode Type Description 'Point as centre of building and lying within its bounds (e.g. for u-shaped building)';
Geocode Type 'CDF' is called Geocode Type Name 'CENTRE-LINE DROPPED FRONTAGE';
Geocode Type 'CDF' has Geocode Type Description 'A point on the road centre-line opposite the centre of the road frontage of an address site';
Geocode Type 'DF' is called Geocode Type Name 'DRIVEWAY FRONTAGE';
Geocode Type 'DF' has Geocode Type Description 'Centre of driveway on address site frontage';
Geocode Type 'EA' is called Geocode Type Name 'EMERGENCY ACCESS';
Geocode Type 'EA' has Geocode Type Description 'Specific building or property access point for emergency services';
Geocode Type 'EAS' is called Geocode Type Name 'EMERGENCY ACCESS SECONDARY';
Geocode Type 'EAS' has Geocode Type Description 'Specific building or property secondary access point for emergency services';
Geocode Type 'FDA' is called Geocode Type Name 'FRONT DOOR ACCESS';
Geocode Type 'FDA' has Geocode Type Description 'Front door of building';
Geocode Type 'FC' is called Geocode Type Name 'FRONTAGE CENTRE';
Geocode Type 'FC' has Geocode Type Description 'Point on the centre of the address site frontage';
Geocode Type 'FCS' is called Geocode Type Name 'FRONTAGE CENTRE SETBACK';
Geocode Type 'FCS' has Geocode Type Description 'A point set back from the centre of the road frontage within an address site';
Geocode Type 'LB' is called Geocode Type Name 'LETTERBOX';
Geocode Type 'LB' has Geocode Type Description 'Place where mail is deposited';
Geocode Type 'PAP' is called Geocode Type Name 'PROPERTY ACCESS POINT';
Geocode Type 'PAP' has Geocode Type Description 'Access point (centre of) at the road frontage of the property';
Geocode Type 'PAPS' is called Geocode Type Name 'PROPERTY ACCESS POINT SETBACK';
Geocode Type 'PAPS' has Geocode Type Description 'A point set back from the (centre of the) access point at the road frontage of the property';
Geocode Type 'PC' is called Geocode Type Name 'PROPERTY CENTROID';
Geocode Type 'PC' has Geocode Type Description 'Point of centre of parcels making up a property and lying within its boundaries (e.g. for l-shaped property)';
Geocode Type 'PCM' is called Geocode Type Name 'PROPERTY CENTROID MANUAL';
Geocode Type 'PCM' has Geocode Type Description 'Point manually placed approximately at centre of parcels making up a property and lying within its boundaries (e.g. for l-shaped property)';
Geocode Type 'UC' is called Geocode Type Name 'UNIT CENTROID';
Geocode Type 'UC' has Geocode Type Description 'Point at centre of unit and lying within its bounds (e.g. for u-shaped unit)';
Geocode Type 'UCM' is called Geocode Type Name 'UNIT CENTROID MANUAL';
Geocode Type 'UCM' has Geocode Type Description 'Point manually placed approximately at centre of unit and lying within its bounds (e.g. for u-shaped unit)';
Geocode Type 'GG' is called Geocode Type Name 'GAP GEOCODE';
Geocode Type 'GG' has Geocode Type Description 'Point programmatically allocated during the g-naf production process proportionally between adjacent address locations (based on number_first)';
Geocode Type 'WCP' is called Geocode Type Name 'WATER CONNECTION POINT WATER CONNECTION POINT (E.G. BOX, OR UNDERGROUND CHAMBER)';
Geocode Type 'WM' is called Geocode Type Name 'WATER METER';
Geocode Type 'WM' has Geocode Type Description 'Water meter point (e.g. box, or underground chamber)';
Geocode Type 'SCP' is called Geocode Type Name 'SEWERAGE CONNECTION POINT';
Geocode Type 'SCP' has Geocode Type Description 'Sewerage connection point (e.g. box, or underground chamber)';
Geocode Type 'GCP' is called Geocode Type Name 'GAS CONNECTION POINT';
Geocode Type 'GCP' has Geocode Type Description 'Gas connection point (e.g. box, or underground chamber)';
Geocode Type 'GM' is called Geocode Type Name 'GAS METER';
Geocode Type 'GM' has Geocode Type Description 'Gas meter point (e.g. box, or underground chamber)';
Geocode Type 'TCP' is called Geocode Type Name 'TELEPHONE CONNECTION POINT';
Geocode Type 'TCP' has Geocode Type Description 'Telephone connection point (e.g. box, or underground chamber)';
Geocode Type 'ECP' is called Geocode Type Name 'ELECTRICITY CONNECTION POINT';
Geocode Type 'ECP' has Geocode Type Description 'Electricity connection point (e.g. box, or underground chamber)';
Geocode Type 'EM' is called Geocode Type Name 'ELECTRICITY METER';
Geocode Type 'EM' has Geocode Type Description 'Electricity meter point (e.g. box, or underground chamber)';
Geocode Type 'ICP' is called Geocode Type Name 'INTERNET CONNECTION POINT';
Geocode Type 'ICP' has Geocode Type Description 'Internet connection point (e.g. box, or underground chamber)';
Geocode Type 'UNK' is called Geocode Type Name 'UNKNOWN';
Geocode Type 'UNK' has Geocode Type Description 'The type of real world feature the point represents is not known';
Geocode Type 'STL' is called Geocode Type Name 'STREET LOCALITY';
Geocode Type 'STL' has Geocode Type Description 'Point representing the extent of a street within a locality';
Geocode Type 'LOC' is called Geocode Type Name 'LOCALITY';
Geocode Type 'LOC' has Geocode Type Description 'Point representing a locality';

/*
 * State table [static]
 */
each State Name is written as a String(50, Search: 'typo');
each State Abbreviation is written as a String(3, Search: 'alpha');
each State [static] is independent identified by its PID;
State is valid for at most one valid- Date Range;
State is called one State Name,
    State Name is of at most one State;
State has one State Abbreviation;
example: State Abbreviation 'TAS';
example: State Name 'TASMANIA';

/*
 * Locality Class table [static]
 */
each Locality Class Code is written as a Char(1);
each Locality Class [static] is identified by Code where
    Locality Class has one Locality Class Code (as Code),
    Code is for at most one Locality Class;
each Locality Class Name is written as a String(50);
each Locality Class Description is written as a Char(30);
Locality Class is called one Locality Class Name (as Name);
Locality Class has at most one Locality Class Description (as Description);
Locality Class 'A' is called Locality Class Name 'ALIAS ONLY LOCALITY';
Locality Class 'D' is called Locality Class Name 'DISTRICT';
Locality Class 'G' is called Locality Class Name 'GAZETTED';
Locality Class 'H' is called Locality Class Name 'HUNDRED';
Locality Class 'M' is called Locality Class Name 'MANUALLY';
Locality Class 'T' is called Locality Class Name 'TOPOGRAPHIC LOCALITY';
Locality Class 'U' is called Locality Class Name 'UNOFFICIAL SUBURB';
Locality Class 'V' is called Locality Class Name 'UNOFFICIAL TOPOGRAPHIC FEATURE';

/*
 * Locality table
 */
each Locality is independent identified by its PID;
Locality is valid for at most one valid- Date Range;
each Locality Name is written as a String(100, Search: 'phonetic');
Locality is called one Locality Name;
Locality has at most one primary- Postcode;
Locality has one Locality Class;
Locality is in one State;
each GNAFLocality is identified by its PID; // Used for internal management purposes by GNAF.
Locality is at most one GNAFLocality;
Locality has one GNAF Reliability restricted to {5, 6};

/*
 * Locality Alias, provides an alternate name, postcode, state for a Locality
 */
each Locality Alias Type Code is written as a String(10);
each Locality Alias Type Name is written as a String(50);
each Locality Alias Type Description is written as a String(100);
each Locality Alias Type [static] is independent identified by Code where
    Locality Alias Type has one Locality Alias Type Code (as Code),
    Code is for at most one Locality Alias Type;
Locality Alias Type is called one Locality Alias Type Name (as Name);
Locality Alias Type has at most one Locality Alias Type Description (as Description);
Locality Alias Type 'SR' is called Locality Alias Type Name 'Spatially Related';
Locality Alias Type 'SYN' is called Locality Alias Type Name 'Synonym';

each Locality Alias is identified by its PID;
Locality Alias has one valid-Date Range;
Locality Alias is alias for one Locality;
Locality Alias is called one Locality Name (as Name);
Locality Alias has at most one Postcode;
Locality Alias has one Locality Alias Type (as Alias Type);
Locality Alias is in one State;

/*
 * Locality Neighbour
 */
each Locality Neighbour is identified by its PID where
    some Locality has some neighbour-Locality;
Locality Neighbour has one valid-Date Range;

/*
 * Street Class [static]
 */
each Street Class Code is written as a Char(1);
each Street Class Name is written as a String(50);
each Street Class Description is written as a String(200);
each Street Class [static] is independent identified by Code where
    Street Class has one Street Class Code (as Code),
    Code is for at most one Street Class;
Street Class is called one Street Class Name (as Name);
Street Class has at most one Street Class Description (as Description);
Street Class 'C' is called Street Class Name 'Confirmed';
Street Class 'U' is called Street Class Name 'Unconfirmed';

/*
 * Street Type [static]
 */
each Street Type Code is written as a Char(15);
each Street Type Name is written as a String(50, Search: 'typo');
each Street Type Description is written as a String(15);
each Street Type [static] is independent identified by Code where
    Street Type has one Street Type Code (as Code),
    Code is for at most one Street Type;
Street Type is called one Street Type Name (as Name),
    Name is of at most one Street Type;
Street Type has at most one Street Type Description (as Description);
// example: Street Type '' is called Street Type Name '';
// Too many to list here

/*
 * Street Suffix [static]
 */
each Street Suffix Code is written as a String(15, Search: 'none');
each Street Suffix Name is written as a String(50, Search: 'typo');
each Street Suffix Description is written as a Char(30);
each Street Suffix [static] is independent identified by Code where
    Street Suffix has one Street Suffix Code (as Code),
    Code is for at most one Street Suffix;
Street Suffix is called one Street Suffix Name (as Name),
    Name is of at most one Street Suffix;
Street Suffix has at most one Street Suffix Description (as Description);
Street Suffix 'CN' is called Street Suffix Name 'CENTRAL';
Street Suffix 'DE' is called Street Suffix Name 'DEVIATION';
Street Suffix 'E' is called Street Suffix Name 'EAST';
Street Suffix 'EX' is called Street Suffix Name 'EXTENSION';
Street Suffix 'LR' is called Street Suffix Name 'LOWER';
Street Suffix 'ML' is called Street Suffix Name 'MALL';
Street Suffix 'N' is called Street Suffix Name 'NORTH';
Street Suffix 'NE' is called Street Suffix Name 'NORTH EAST';
Street Suffix 'NW' is called Street Suffix Name 'NORTH WEST';
Street Suffix 'S' is called Street Suffix Name 'SOUTH';
Street Suffix 'SE' is called Street Suffix Name 'SOUTH EAST';
Street Suffix 'SW' is called Street Suffix Name 'SOUTH WEST';
Street Suffix 'UP' is called Street Suffix Name 'UPPER';
Street Suffix 'W' is called Street Suffix Name 'WEST';
Street Suffix 'IN' is called Street Suffix Name 'INNER';
Street Suffix 'OF' is called Street Suffix Name 'OFF';
Street Suffix 'ON' is called Street Suffix Name 'ON';
Street Suffix 'OP' is called Street Suffix Name 'OVERPASS';
Street Suffix 'OT' is called Street Suffix Name 'OUTER';

/*
 * Street Locality
 * A Street may pass through more than one Locality. We manage the segments independently.
 */
each Street Name is written as a String(100, restricts Search to {'alpha', 'phonetic'});
each Street Locality is independent identified by its PID;
Street Locality has one valid-Date Range;
Street Locality has one Street Class;
Street Locality has at most one Street Type;
Street Locality is called one Street Name;
Street Locality has at most one Street Suffix;
Street Locality is in one Locality;
each GNAF Street is identified by its PID; // Used for internal management purposes by GNAF.
Street Locality is at most one GNAF Street;
Street Locality has at most one GNAF- Street Confidence;
Street Locality has at most one GNAF Reliability;

/*
 * Street Locality Alias Type [static]
 */
each Street Locality Alias Type Code is written as a String(10, Search: 'none');
each Street Locality Alias Type Name is written as a Char(50);
each Street Locality Alias Type Description is written as a Char(30);
each Street Locality Alias Type [static] is independent identified by Code where
    Street Locality Alias Type has one Street Locality Alias Type Code (as Code),
    Code is for at most one Street Locality Alias Type;
Street Locality Alias Type is called one Street Locality Alias Type Name (as Name);
Street Locality Alias Type has at most one Street Locality Alias Type Description (as Description);
Street Locality Alias Type 'ALT' is called Street Locality Alias Type Name 'Alternative';
Street Locality Alias Type 'SYN' is called Street Locality Alias Type Name 'Synonym';

/*
 * Street Locality Alias
 */
each Street Locality Alias is identified by its PID;
Street Locality Alias has one valid-Date Range;
Street Locality Alias is an alias for one Street Locality;
Street Locality Alias is called one Street Name;
Street Locality Alias has at most one Street Type;
Street Locality Alias has at most one Street Suffix;
Street Locality Alias has at most one Street Locality Alias Type;

/*
 * Street Locality Point
 * omitted, not useful to us.
 */

/*
 * Flat Type [static]
 */
each Flat Type Code is written as a Char(7);
each Flat Type Name is written as a String(50, Search: 'typo');
each Flat Type Description is written as a Char(30);
each Flat Type [static] is independent identified by Code where
    Flat Type has one Flat Type Code (as Code),
    Code is for at most one Flat Type;
Flat Type is called one Flat Type Name (as Name),
    Name is of at most one Flat Type;
Flat Type has one Flat Type Description (as Description);
Flat Type 'ANT' is called Flat Type Name 'ANTENNA';
Flat Type 'APT' is called Flat Type Name 'APARTMENT';
Flat Type 'ATM' is called Flat Type Name 'AUTOMATED TELLER MACHINE';
Flat Type 'BBQ' is called Flat Type Name 'BARBECUE';
Flat Type 'BLCK' is called Flat Type Name 'BLOCK';
Flat Type 'BLDG' is called Flat Type Name 'BUILDING';
Flat Type 'BNGW' is called Flat Type Name 'BUNGALOW';
Flat Type 'BTSD' is called Flat Type Name 'BOATSHED';
Flat Type 'CAGE' is called Flat Type Name 'CAGE';
Flat Type 'CARP' is called Flat Type Name 'CARPARK';
Flat Type 'CARS' is called Flat Type Name 'CARSPACE';
Flat Type 'CLUB' is called Flat Type Name 'CLUB';
Flat Type 'COOL' is called Flat Type Name 'COOLROOM';
Flat Type 'CTGE' is called Flat Type Name 'COTTAGE';
Flat Type 'DUPL' is called Flat Type Name 'DUPLEX';
Flat Type 'FCTY' is called Flat Type Name 'FACTORY';
Flat Type 'FLAT' is called Flat Type Name 'FLAT';
Flat Type 'GRGE' is called Flat Type Name 'GARAGE';
Flat Type 'HALL' is called Flat Type Name 'HALL';
Flat Type 'HSE' is called Flat Type Name 'HOUSE';
Flat Type 'KSK' is called Flat Type Name 'KIOSK';
Flat Type 'LBBY' is called Flat Type Name 'LOBBY';
Flat Type 'LOFT' is called Flat Type Name 'LOFT';
Flat Type 'LOT' is called Flat Type Name 'LOT';
Flat Type 'LSE' is called Flat Type Name 'LEASE';
Flat Type 'MBTH' is called Flat Type Name 'MARINE BERTH';
Flat Type 'MSNT' is called Flat Type Name 'MAISONETTE';
Flat Type 'OFFC' is called Flat Type Name 'OFFICE';
Flat Type 'PTHS' is called Flat Type Name 'PENTHOUSE';
Flat Type 'REAR' is called Flat Type Name 'REAR';
Flat Type 'RESV' is called Flat Type Name 'RESERVE';
Flat Type 'ROOM' is called Flat Type Name 'ROOM';
Flat Type 'SE' is called Flat Type Name 'SUITE';
Flat Type 'SEC' is called Flat Type Name 'SECTION';
Flat Type 'SHED' is called Flat Type Name 'SHED';
Flat Type 'SHOP' is called Flat Type Name 'SHOP';
Flat Type 'SHRM' is called Flat Type Name 'SHOWROOM';
Flat Type 'SIGN' is called Flat Type Name 'SIGN';
Flat Type 'SITE' is called Flat Type Name 'SITE';
Flat Type 'STLL' is called Flat Type Name 'STALL';
Flat Type 'STOR' is called Flat Type Name 'STORE';
Flat Type 'STR' is called Flat Type Name 'STRATA UNIT';
Flat Type 'STU' is called Flat Type Name 'STUDIO';
Flat Type 'SUBS' is called Flat Type Name 'SUBSTATION';
Flat Type 'TNCY' is called Flat Type Name 'TENANCY';
Flat Type 'TNHS' is called Flat Type Name 'TOWNHOUSE';
Flat Type 'TWR' is called Flat Type Name 'TOWER';
Flat Type 'UNIT' is called Flat Type Name 'UNIT';
Flat Type 'VLLA' is called Flat Type Name 'VILLA';
Flat Type 'VLT' is called Flat Type Name 'VAULT';
Flat Type 'WARD' is called Flat Type Name 'WARD';
Flat Type 'WHSE' is called Flat Type Name 'WAREHOUSE';
Flat Type 'WKSH' is called Flat Type Name 'WORKSHOP';

/*
 * Level Type [static]
 */
each Level Type Code is written as a Char(4);
each Level Type Name is written as a String(50, Search: 'typo');
each Level Type Description is written as a Char(30);
each Level Type [static] is independent identified by Code where
    Level Type has one Level Type Code (as Code),
    Code is for at most one Level Type;
Level Type is called one Level Type Name (as Name),
    Name is of at most one Level Type;
Level Type has one Level Type Description (as Description);
Level Type 'B' is called Level Type Name 'BASEMENT';
Level Type 'P' is called Level Type Name 'PARKING';
Level Type 'FL' is called Level Type Name 'FLOOR';
Level Type 'PTHS' is called Level Type Name 'PENTHOUSE';
Level Type 'G' is called Level Type Name 'GROUND';
Level Type 'PDM' is called Level Type Name 'PODIUM';
Level Type 'L' is called Level Type Name 'LEVEL';
Level Type 'LB' is called Level Type Name 'LOBBY';
Level Type 'PLF' is called Level Type Name 'PLATFORM';
Level Type 'RT' is called Level Type Name 'ROOFTOP';
Level Type 'LG' is called Level Type Name 'LOWER GROUND FLOOR';
Level Type 'SB' is called Level Type Name 'SUB-BASEMENT';
Level Type 'M' is called Level Type Name 'MEZZANINE';
Level Type 'UG' is called Level Type Name 'UPPER GROUND FLOOR';
Level Type 'OD' is called Level Type Name 'OBSERVATION DECK';

/*
 * Address Type [static]
 */
each Address Type Code is written as a String(8, Search: 'none');
each Address Type Name is written as a String(50);
each Address Type Description is written as a String(30);
each Address Type [static] is independent identified by Code where
    Address Type has one Address Type Code (as Code),
    Code is for at most one Address Type;
// Name is not always unique; c.f. Unknown Roadside Mail Service which has two codes
Address Type is called one Address Type Name (as Name),
    Name is of Address Type;
Address Type has at most one Address Type Description (as Description);
Address Type 'R' is called Address Type Name 'Rural';
Address Type 'UN' is called Address Type Name 'Unknown';
Address Type 'UR' is called Address Type Name 'Urban';
Address Type 'R/BLOCK' is called Address Type Name 'Rural Block';
Address Type 'R/CABIN' is called Address Type Name 'Rural Cabin';
Address Type 'R/FLAT' is called Address Type Name 'Rural Flat';
Address Type 'R/HOUSE' is called Address Type Name 'Rural House';
Address Type 'R/LOT' is called Address Type Name 'Rural Lot';
Address Type 'R/RES' is called Address Type Name 'Rural Reserve';
Address Type 'R/RMB' is called Address Type Name 'Rural Roadside mail box';
Address Type 'R/ROOM' is called Address Type Name 'Rural Room';
Address Type 'R/RSD' is called Address Type Name 'Rural Roadside mail delivery';
Address Type 'R/RSM' is called Address Type Name 'Rural Roadside mail service';
Address Type 'R/SEC' is called Address Type Name 'Rural Section';
Address Type 'R/SITE' is called Address Type Name 'Rural Site';
Address Type 'R/UNIT' is called Address Type Name 'Rural Unit';
Address Type 'UN/APT' is called Address Type Name 'Unknown Apartment';
Address Type 'UN/BLOCK' is called Address Type Name 'Unknown Block';
Address Type 'UN/CABIN' is called Address Type Name 'Unknown Cabin';
Address Type 'UN/CTGE' is called Address Type Name 'Unknown Cottage';
Address Type 'UN/CVAN' is called Address Type Name 'Unknown Caravan';
Address Type 'UN/FARM' is called Address Type Name 'Unknown Farm';
Address Type 'UN/FLAT' is called Address Type Name 'Unknown Flat';
Address Type 'UN/GD' is called Address Type Name 'Unknown Ground Floor';
Address Type 'UN/HOUSE' is called Address Type Name 'Unknown House';
Address Type 'UN/LOC' is called Address Type Name 'Unknown Location';
Address Type 'UN/LOT' is called Address Type Name 'Unknown Lot';
Address Type 'UN/LWR' is called Address Type Name 'Unknown Lower';
Address Type 'UN/POR' is called Address Type Name 'Unknown Portion';
Address Type 'UN/PTHS' is called Address Type Name 'Unknown Penthouse';
Address Type 'UN/REAR' is called Address Type Name 'Unknown Rear';
Address Type 'UN/RES' is called Address Type Name 'Unknown Reserve';
Address Type 'UN/RMB' is called Address Type Name 'Unknown Roadside mail box';
Address Type 'UN/RMS' is called Address Type Name 'Unknown Roadside mail service';
Address Type 'UN/ROOM' is called Address Type Name 'Unknown Room';
Address Type 'UN/RSD' is called Address Type Name 'Unknown Roadside mail delivery';
Address Type 'UN/RSM' is called Address Type Name 'Unknown Roadside mail service';
Address Type 'UN/SEC' is called Address Type Name 'Unknown Section';
Address Type 'UN/SITE' is called Address Type Name 'Unknown Site';
Address Type 'UN/TNHS' is called Address Type Name 'Unknown Townhouse';
Address Type 'UN/UNIT' is called Address Type Name 'Unknown Unit';
Address Type 'UN/VLLA' is called Address Type Name 'Unknown Villa';
Address Type 'UR/BLOCK' is called Address Type Name 'Urban Block';
Address Type 'UR/CABIN' is called Address Type Name 'Urban Cabin';
Address Type 'UR/FLAT' is called Address Type Name 'Urban Flat';
Address Type 'UR/HOUSE' is called Address Type Name 'Urban House';
Address Type 'UR/LOT' is called Address Type Name 'Urban Lot';
Address Type 'UR/RES' is called Address Type Name 'Urban Reserve';
Address Type 'UR/RMB' is called Address Type Name 'Urban Roadside mail box';
Address Type 'UR/RMS' is called Address Type Name 'Unknown Roadside mail service';
Address Type 'UR/ROOM' is called Address Type Name 'Urban Room';
Address Type 'UR/RSD' is called Address Type Name 'Urban Roadside mail delivery';
Address Type 'UR/RSM' is called Address Type Name 'Urban Roadside mail service';
Address Type 'UR/SEC' is called Address Type Name 'Urban Section';
Address Type 'UR/SITE' is called Address Type Name 'Urban Site';
Address Type 'UR/UNIT' is called Address Type Name 'Urban Unit';

/*
 * Address Site
 * For all places, not just ones that have an address
 */
each Address Site Name is written as a String(45, Search: 'words');	// Equates Complex name of AS4590.8.5.
each Address Site is independent identified by its PID;
Address Site is valid for at most one valid- Date Range;
Address Site is of at most one Address Type;		// Comment says (e.g. "Postal", Physical")
Address Site is called at most one Address Site Name,
    Address Site Name is of Address Site;
each Address Site occurs at most one time in
    Address Site is of Address Type,
    Address Site is called Address Site Name;

/*
 * Address Detail
 */
each Address Detail is independent identified by its PID;
Address Detail is valid for at most one valid- Date Range;

Address Detail (as AliasPrincipal) is principal;	// Char(1) in G-NAF
Address Detail is in one Locality;
Address Detail has at most one Postcode;

each Address Number is written as a Numeric Fragment(Search: 'alpha');

each Number First Prefix is written as a Address Number(3);
each Number First is written as a Address Number(6);
each Number First Suffix is written as a Address Number(2);
each Number Last Prefix is written as a Address Number(3);
each Number Last is written as a Address Number(6);
each Number Last Suffix is written as a Address Number(2);
each Flat Number Prefix is written as a Address Number(2);
each Flat Number is written as a Address Number(5);
each Flat Number Suffix is written as a Address Number(2);
each Level Number Prefix is written as a Address Number(2);
each Level Number is written as a Address Number(3);
each Level Number Suffix is written as a Address Number(2);
each Lot Number Prefix is written as a Address Number(3);
each Lot Number is written as a Address Number(6);
each Lot Number Suffix is written as a Address Number(2);

each Building Name is written as a String(45, Search: 'phonetic');
each Location Description is written as a String(45, Search: 'text');
each Private Street is written as a String(75, Search: 'text');
each Legal Parcel Id is written as a String(20, Search: 'alpha');
each GNAF Property PID is written as a PID;

Address Detail has at most one Number First Prefix;
Address Detail has at most one Number First;
Address Detail has at most one Number First Suffix;
Address Detail has at most one Number Last Prefix;
Address Detail has at most one Number Last;
Address Detail has at most one Number Last Suffix;
Address Detail has at most one Flat Number Prefix;
Address Detail has at most one Flat Number;
Address Detail has at most one Flat Number Suffix;
Address Detail has at most one Level Number Prefix;
Address Detail has at most one Level Number;
Address Detail has at most one Level Number Suffix;
Address Detail has at most one Lot Number Prefix;
Address Detail has at most one Lot Number;
Address Detail has at most one Lot Number Suffix;

Address Detail is at most one Flat Type;
Address Detail has at most one Level Type;
Address Detail is geocoded to one Geocoded Level Type (as Level Geocoded);
Address Detail is in at most one Street Locality;

Address Detail has at most one Building Name;
Address Detail has at most one Location Description;
Address Detail is at most one Private Street;
Address Detail is at most one Legal Parcel Id;
Address Detail has at most one Confidence;
// each PropertyPID is written as a PID;	    // Not populated
Address Detail is in one Address Site;
Address Detail has at most one GNAF Property PID;   // under review
Address Detail is secondary;	    // Primary Secondary, Char(1) in GNAF

each Address Detail occurs at most one time in
    Address Detail is in Locality,
    Address Detail has Postcode,
    Address Detail is in Street Locality,
    Address Detail has Number First Prefix,
    Address Detail has Number First,
    Address Detail has Number First Suffix,
    Address Detail has Number Last Prefix,
    Address Detail has Number Last,
    Address Detail has Number Last Suffix,
    Address Detail has Flat Number Prefix,
    Address Detail has Flat Number,
    Address Detail has Flat Number Suffix,
    Address Detail has Level Number;

/*
 * Address Alias Type [static]
 */
each Address Alias Type Code is written as a String(10);
each Address Alias Type Name is written as a String(50);
each Address Alias Type Description is written as a String(30);
each Address Alias Type [static] is independent identified by Code where
    Address Alias Type has one Address Alias Type Code (as Code),
    Code is for at most one Address Alias Type;
Address Alias Type is called one Address Alias Type Name (as Name);
Address Alias Type has at most one Address Alias Type Description (as Description);
Address Alias Type 'SYN' is called Address Alias Type Name 'Synonym';
Address Alias Type 'CD' is called Address Alias Type Name 'Contributor Defined';
Address Alias Type 'AL' is called Address Alias Type Name 'Alternative Locality';
Address Alias Type 'RA' is called Address Alias Type Name 'Ranged Address';
Address Alias Type 'LD' is called Address Alias Type Name 'Level Duplication';
Address Alias Type 'FNNFS' is called Address Alias Type Name 'Flat Number – No First Suffix Correlation';
Address Alias Type 'MR' is called Address Alias Type Name 'Maintenance Reference';

/*
 * Address Alias
 */
each Address Alias is identified by its PID where
    some Address Detail (as Alias) is an alias for some Address Detail (as Principal);
Address Alias is valid for most one valid- Date Range;
Address Alias has one Address Alias Type;
each Address Alias Comment is written as a String(200);
Address Alias has at most one Address Alias Comment;

/*
 * Primary/Secondary address linkage.
 * This is how e.g. a flat is joined to the block of flats
 */
each PS Join Type Code is written as a Decimal(2);
each PS Join Type Name is written as a String(50);
each PS Join Type Description is written as a String(500);
each PS Join Type [static] is identified by Code where
    PS Join Type has one PS Join Type Code (as Code),
    Code is for at most one PS Join Type;
PS Join Type is called one PS Join Type Name (as Name);
PS Join Type has at most one PS Join Type Description (as Description);
PS Join Type 1 is called PS Join Type Name 'Auto';
PS Join Type 1 has PS Join Type Description 'Automatically matched primary and secondary, both parent and child have the same root address';
PS Join Type 2 is called PS Join Type Name 'Manual';
PS Join Type 2 has PS Join Type Description 'Manually generated link, may or may not have the same root address';

each PS Join Comment is written as a String(500);
each Primary Secondary is identified by its PID;
Primary Secondary is valid for at most one valid- Date Range;
Primary Secondary has one Address Detail;	// Column name should be PRIMARY_PID
Primary Secondary has one secondary- Address Detail (as Secondary);	// Column name should be SECONDARY_PID
Primary Secondary is of one PS Join Type;
Primary Secondary has at most one PS Join Comment;

/*
 * Address Geocodes
 */
each Address Default Geocode is identified by its PID where
    some Geocode Type applies to some Address Detail;
Address Default Geocode is valid for at most one valid- Date Range;
Address Default Geocode has one Latitude;
Address Default Geocode has one Longitude;

/*
 * Address Site geocode
 */
each Geocode Site Name is written as a String(46);
each Geocode Site Description is written as a String(46);
each Boundary Extent is written as a Decimal(7); // in metres
each Planimetric Accuracy is written as a Decimal(12);
each Address Site Geocode is identified by its PID;
Address Site Geocode is valid for at most one valid- Date Range;
Address Site Geocode is at at most one Address Site;
Address Site Geocode is called at most one Geocode Site Name;
Address Site Geocode has at most one Geocode Site Description;
Address Site Geocode is of at most one Geocode Type;
Address Site Geocode has one Geocode Reliability (as Reliability);
Address Site Geocode has at most one Boundary Extent;
Address Site Geocode has at most one Planimetric Accuracy;
// Address Site Geocode has at most one Elevation;  // Not available
Address Site Geocode has one Longitude;
Address Site Geocode has one Latitude;
