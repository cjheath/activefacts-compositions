/*
 * A schema for testing separate and partitioned subtypes
 */
schema Separate;

// Value Types
each GUID is written as GUID auto-assigned at assert;
each Val is written as Val;
each Key is written as GUID;

// A type, to be a partitioned subtype with its own identifier
each PartitionInd is identified by its Key;

// Define a new base type:
each Base is independent identified by its GUID;
Base has one base-Val;

// Retro-actively define a new supertype for PartitionInd:
each PartitionInd is a kind of Base [partitioned];

/* An absorbed subtype of the first partitioned subtype
*/
each AbsorbedPart is a kind of PartitionInd;
AbsorbedPart has one abs- part Val;

/* An additional partitioned subtype:
*/
each Partition is a kind of Base [partitioned];
Partition has one part- Val;

/* A separate subtype:
*/
each Separate is a kind of Base [separate];
Separate has one sep- Val;

/* The following subtype is absorbed.
 * It has roles that should not be absorbed into the partitioned types:
 * PENDING
each Absorbed is a kind of Base;
Absorbed has one abs- Val;
*/

/* The following subtype is absorbed.
 * It has roles that should not be absorbed into the partitioned types:
 * PENDING
each AbsorbedInd is a kind of Base identified by its GUID;
AbsorbedInd has one abs- ind Val;
*/
