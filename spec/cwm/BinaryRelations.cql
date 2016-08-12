vocabulary BinaryRelations;

/*
 * Binary relationships:
 * 
 * 16 Cases from the cross product of 4 cardinalities for each reading:
 *    one (One)
 *    at most one (Most)
 *    at least one (Least)
 *    many (Many)
 *  
 * Three test scenarios:
 *    Entity to Entity
 *    Entity to Value
 *    Value to Entity
 */


ID is written as String;

/*
 * One to One
 */

// Entity to Entity

CA_OneOne is written as String;
EA_OneOne is identified by its ID;
EA_OneOne has one CA_OneOne;

CB_OneOne is written as String;
EB_OneOne is identified by its ID;
EB_OneOne has one CB_OneOne;

EA_OneOne has one EB_OneOne, EB_OneOne has one EA_OneOne;

// Entity to Value

VB_OneOne is written as String;

EA_OneOne has one VB_OneOne, VB_OneOne has one EA_OneOne;

// Value to Entity

VA_OneOne is written as String;

VA_OneOne has one EB_OneOne, EB_OneOne has one VA_OneOne;

/*
 * One to Most
 */

// Entity to Entity

CA_OneMost is written as String;
EA_OneMost is identified by its ID;
EA_OneMost has one CA_OneMost;

CB_OneMost is written as String;
EB_OneMost is identified by its ID;
EB_OneMost has one CB_OneMost;

EA_OneMost has one EB_OneMost, EB_OneMost has at most one EA_OneMost;

// Entity to Value

VB_OneMost is written as String;

EA_OneMost has one VB_OneMost, VB_OneMost has at most one EA_OneMost;

// Value to Entity

VA_OneMost is written as String;

VA_OneMost has one EB_OneMost, EB_OneMost has at most one VA_OneMost;

/*
 * One to Least
 */

// Entity to Entity

CA_OneLeast is written as String;
EA_OneLeast is identified by its ID;
EA_OneLeast has one CA_OneLeast;

CB_OneLeast is written as String;
EB_OneLeast is identified by its ID;
EB_OneLeast has one CB_OneLeast;

EA_OneLeast has one EB_OneLeast, EB_OneLeast has at least one EA_OneLeast;

// Entity to Value

VB_OneLeast is written as String;

EA_OneLeast has one VB_OneLeast, VB_OneLeast has at least one EA_OneLeast;

// Value to Entity

VA_OneLeast is written as String;

VA_OneLeast has one EB_OneLeast, EB_OneLeast has at least one VA_OneLeast;

/*
 * One to Many
 */

// Entity to Entity

CA_OneMany is written as String;
EA_OneMany is identified by its ID;
EA_OneMany has one CA_OneMany;

CB_OneMany is written as String;
EB_OneMany is identified by its ID;
EB_OneMany has one CB_OneMany;

EA_OneMany has one EB_OneMany, EB_OneMany has EA_OneMany;

// Entity to Value

VB_OneMany is written as String;

EA_OneMany has one VB_OneMany, VB_OneMany has EA_OneMany;

// Value to Entity

VA_OneMany is written as String;

VA_OneMany has one EB_OneMany, EB_OneMany has VA_OneMany;

/*
 * Most to One
 */

// Entity to Entity

CA_MostOne is written as String;
EA_MostOne is identified by its ID;
EA_MostOne has one CA_MostOne;

CB_MostOne is written as String;
EB_MostOne is identified by its ID;
EB_MostOne has one CB_MostOne;

EA_MostOne has at most one EB_MostOne, EB_MostOne has one EA_MostOne;

// Entity to Value

VB_MostOne is written as String;

EA_MostOne has at most one VB_MostOne, VB_MostOne has one EA_MostOne;

// Value to Entity

VA_MostOne is written as String;

VA_MostOne has at most one EB_MostOne, EB_MostOne has one VA_MostOne;

/*
 * Most to Most
 */

// Entity to Entity

CA_MostMost is written as String;
EA_MostMost is identified by its ID;
EA_MostMost has one CA_MostMost;

CB_MostMost is written as String;
EB_MostMost is identified by its ID;
EB_MostMost has one CB_MostMost;

EA_MostMost has at most one EB_MostMost, EB_MostMost has at most one EA_MostMost;

// Entity to Value

VB_MostMost is written as String;

EA_MostMost has at most one VB_MostMost, VB_MostMost has at most one EA_MostMost;

// Value to Entity

VA_MostMost is written as String;

VA_MostMost has at most one EB_MostMost, EB_MostMost has at most one VA_MostMost;

/*
 * Most to Least
 */

// Entity to Entity

CA_MostLeast is written as String;
EA_MostLeast is identified by its ID;
EA_MostLeast has one CA_MostLeast;

CB_MostLeast is written as String;
EB_MostLeast is identified by its ID;
EB_MostLeast has one CB_MostLeast;

EA_MostLeast has at most one EB_MostLeast, EB_MostLeast has at least one EA_MostLeast;

// Entity to Value

VB_MostLeast is written as String;

EA_MostLeast has at most one VB_MostLeast, VB_MostLeast has at least one EA_MostLeast;

// Value to Entity

VA_MostLeast is written as String;

VA_MostLeast has at most one EB_MostLeast, EB_MostLeast has at least one VA_MostLeast;

/*
 * Most to Many
 */

// Entity to Entity

CA_MostMany is written as String;
EA_MostMany is identified by its ID;
EA_MostMany has one CA_MostMany;

CB_MostMany is written as String;
EB_MostMany is identified by its ID;
EB_MostMany has one CB_MostMany;

EA_MostMany has at most one EB_MostMany, EB_MostMany has EA_MostMany;

// Entity to Value

VB_MostMany is written as String;

EA_MostMany has at most one VB_MostMany, VB_MostMany has EA_MostMany;

// Value to Entity

VA_MostMany is written as String;

VA_MostMany has at most one EB_MostMany, EB_MostMany has VA_MostMany;

/*
 * Least to One
 */

// Entity to Entity

CA_LeastOne is written as String;
EA_LeastOne is identified by its ID;
EA_LeastOne has one CA_LeastOne;

CB_LeastOne is written as String;
EB_LeastOne is identified by its ID;
EB_LeastOne has one CB_LeastOne;

EA_LeastOne has at least one EB_LeastOne, EB_LeastOne has one EA_LeastOne;

// Entity to Value

VB_LeastOne is written as String;

EA_LeastOne has at least one VB_LeastOne, VB_LeastOne has one EA_LeastOne;

// Value to Entity

VA_LeastOne is written as String;

VA_LeastOne has at least one EB_LeastOne, EB_LeastOne has one VA_LeastOne;

/*
 * Least to Most
 */

// Entity to Entity

CA_LeastMost is written as String;
EA_LeastMost is identified by its ID;
EA_LeastMost has one CA_LeastMost;

CB_LeastMost is written as String;
EB_LeastMost is identified by its ID;
EB_LeastMost has one CB_LeastMost;

EA_LeastMost has at least one EB_LeastMost, EB_LeastMost has at most one EA_LeastMost;

// Entity to Value

VB_LeastMost is written as String;

EA_LeastMost has at least one VB_LeastMost, VB_LeastMost has at most one EA_LeastMost;

// Value to Entity

VA_LeastMost is written as String;

VA_LeastMost has at least one EB_LeastMost, EB_LeastMost has at most one VA_LeastMost;

/*
 * Least to Least
 */

// Entity to Entity

CA_LeastLeast is written as String;
EA_LeastLeast is identified by its ID;
EA_LeastLeast has one CA_LeastLeast;

CB_LeastLeast is written as String;
EB_LeastLeast is identified by its ID;
EB_LeastLeast has one CB_LeastLeast;

EAEB_LeastLeast is where
  EA_LeastLeast has at least one EB_LeastLeast, EB_LeastLeast has at least one EA_LeastLeast;

// Entity to Value

VB_LeastLeast is written as String;

EAVB_LeastLeast is where
  EA_LeastLeast has at least one VB_LeastLeast, VB_LeastLeast has at least one EA_LeastLeast;

// Value to Entity

VA_LeastLeast is written as String;

VAEB_LeastLeast is where
  VA_LeastLeast has at least one EB_LeastLeast, EB_LeastLeast has at least one VA_LeastLeast;

/*
 * Least to Many
 */

// Entity to Entity

CA_LeastMany is written as String;
EA_LeastMany is identified by its ID;
EA_LeastMany has one CA_LeastMany;

CB_LeastMany is written as String;
EB_LeastMany is identified by its ID;
EB_LeastMany has one CB_LeastMany;

EAEB_LeastMany is where
  EA_LeastMany has at least one EB_LeastMany, EB_LeastMany has EA_LeastMany;

// Entity to Value

VB_LeastMany is written as String;

EAVB_LeastMany is where
  EA_LeastMany has at least one VB_LeastMany, VB_LeastMany has EA_LeastMany;

// Value to Entity

VA_LeastMany is written as String;

VAEB_LeastMany is where
  VA_LeastMany has at least one EB_LeastMany, EB_LeastMany has VA_LeastMany;

/*
 * Many to One
 */

// Entity to Entity

CA_ManyOne is written as String;
EA_ManyOne is identified by its ID;
EA_ManyOne has one CA_ManyOne;

CB_ManyOne is written as String;
EB_ManyOne is identified by its ID;
EB_ManyOne has one CB_ManyOne;

EA_ManyOne has many EB_ManyOne, EB_ManyOne has one EA_ManyOne;

// Entity to Value

VB_ManyOne is written as String;

EA_ManyOne has many VB_ManyOne, VB_ManyOne has one EA_ManyOne;

// Value to Entity

VA_ManyOne is written as String;

VA_ManyOne has many EB_ManyOne, EB_ManyOne has one VA_ManyOne;

/*
 * Many to Most
 */

// Entity to Entity

CA_ManyMost is written as String;
EA_ManyMost is identified by its ID;
EA_ManyMost has one CA_ManyMost;

CB_ManyMost is written as String;
EB_ManyMost is identified by its ID;
EB_ManyMost has one CB_ManyMost;

EA_ManyMost has EB_ManyMost, EB_ManyMost has at most one EA_ManyMost;

// Entity to Value

VB_ManyMost is written as String;

EA_ManyMost has VB_ManyMost, VB_ManyMost has at most one EA_ManyMost;

// Value to Entity

VA_ManyMost is written as String;

VA_ManyMost has EB_ManyMost, EB_ManyMost has at most one VA_ManyMost;

/*
 * Many to Least
 */

// Entity to Entity

CA_ManyLeast is written as String;
EA_ManyLeast is identified by its ID;
EA_ManyLeast has one CA_ManyLeast;

CB_ManyLeast is written as String;
EB_ManyLeast is identified by its ID;
EB_ManyLeast has one CB_ManyLeast;

EAEB_ManyLeast is where
  EA_ManyLeast has EB_ManyLeast, EB_ManyLeast has at least one EA_ManyLeast;

// Entity to Value

VB_ManyLeast is written as String;

EAVB_ManyLeast is where
  EA_ManyLeast has VB_ManyLeast, VB_ManyLeast has at least one EA_ManyLeast;

// Value to Entity

VA_ManyLeast is written as String;

VAEB_ManyLeast is where
  VA_ManyLeast has EB_ManyLeast, EB_ManyLeast has at least one VA_ManyLeast;

/*
 * Many to Many
 */

// Entity to Entity

CA_ManyMany is written as String;
EA_ManyMany is identified by its ID;
EA_ManyMany has one CA_ManyMany;

CB_ManyMany is written as String;
EB_ManyMany is identified by its ID;
EB_ManyMany has one CB_ManyMany;

EAEB_ManyMany is where
  EA_ManyMany has EB_ManyMany, EB_ManyMany has EA_ManyMany;

// Entity to Value

VB_ManyMany is written as String;

EAVB_ManyMany is where
  EA_ManyMany has VB_ManyMany, VB_ManyMany has EA_ManyMany;

// Value to Entity

VA_ManyMany is written as String;

VAEB_ManyMany is where
  VA_ManyMany has EB_ManyMany, EB_ManyMany has VA_ManyMany;
