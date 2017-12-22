/*
 * An example of each kind of data type supported by the Metamodel,
 * for the purpose of testing generators.
 */
vocabulary DataTypes;

each Fundamental Boolean is written as Boolean;
each Fundamental Integer is written as Integer;
each Fundamental Real is written as Real;
each Fundamental Decimal is written as Decimal;
each Fundamental Money is written as Money;
each Fundamental Char is written as Char;
each Fundamental String is written as String;
each Fundamental Text is written as Text;
each Fundamental Date is written as Date;
each Fundamental Time is written as Time;
each Fundamental DateTime is written as DateTime;
each Fundamental Timestamp is written as Timestamp;
each Fundamental Binary is written as Binary;

// TYPE_Boolean
each Alternate Bit is written as bit;

// TYPE_Integer
each Alternate Auto Counter is written as Auto Counter;
each Alternate Int is written as Int;
each Alternate Tiny Int is written as Tiny Int;
each Alternate Small Int is written as Small Int;
each Alternate Big Int is written as Big Int;
each Alternate Unsigned is written as Unsigned;
each Alternate Unsigned Int is written as Unsigned Int;
each Alternate Unsigned Integer is written as Unsigned Integer;
each Alternate Signed Int is written as Signed Int;
each Alternate Signed Integer is written as Signed Integer;

// TYPE_Real
each Alternate Float is written as Float;
each Alternate Double is written as Double;

// TYPE_Decimal

// TYPE_Money
each Alternate Currency is written as Currency;

// TYPE_Char
each Alternate Character is written as Character;
each Alternate Nchar is written as Nchar;
each Alternate National Character is written as National Character;
each Alternate Fixed Length Text is written as Fixed Length Text;

// TYPE_String
each Alternate Varchar is written as Varchar;
each Alternate Nvarchar is written as Nvarchar;
each Alternate National Character Varying is written as National Character Varying;
each Alternate Variable Length Text is written as Variable Length Text;

// TYPE_Text
each Alternate Large Length Text is written as Large Length Text;

// TYPE_Date

// TYPE_Time

// TYPE_DateTime
each Alternate Date Time is written as Date Time;

// TYPE_Timestamp
each Alternate Time Stamp is written as Time Stamp;
each Alternate Auto Time Stamp is written as Auto Time Stamp;

// TYPE_Binary
each Guid is written as Guid auto-assigned at assert;
each Alternate Guid is written as Guid;
each Alternate Picture Raw Data is written as Picture Raw Data;
each Alternate Variable Length Raw Data is written as Variable Length Raw Data;

// String types with a length limit
each Char8 is written as Char(8);
each String255 is written as String(255);
each Text65536 is written as Text(65536);

// Integer with different ValueType constraint ranges
each Byte is written as an Integer restricted to {-128..127};
each Word is written as an Integer restricted to {-32768..32767};
each Int is written as an Integer restricted to {-2147483648..2147483647};
each Quad is written as an Integer restricted to {-9223372036854775808..9223372036854775807};
each Large is written as an Integer restricted to {-9223372036854775808999..9223372036854775807999};

each UByte is written as an Integer restricted to {0..255};
each UWord is written as an Integer restricted to {0..65535};
each UInt is written as an Integer restricted to {0..4294967295};
each UQuad is written as an Integer restricted to {0..18446744073709551615};
each ULarge is written as an Integer restricted to {0..184467440737095516159999};

// Integer with different bit lengths
each Int8 is written as an Integer(8);
each Int16 is written as an Integer(16);
each Int32 is written as an Integer(32);
each Int64 is written as an Integer(64);
each Int80 is written as an Integer(80);

// Real with different bit lengths
each Real32 is written as an Real(32);
each Real64 is written as an Real(64);
each Real80 is written as an Real(80);

// Decimal with different scale and precision
each Decimal8_3 is written as an Decimal(8, 3);
each Decimal14 is written as an Decimal(14);
each Decimal14_6 is written as an Decimal(14, 6);

each Name is written as a String;
Container is identified by its Name;

Container has one Fundamental Boolean;
Container has one Fundamental Integer;
Container has one Fundamental Real;
Container has one Fundamental Decimal;
Container has one Fundamental Money;
Container has one Fundamental Char;
Container has one Fundamental String;
Container has one Fundamental Text;
Container has one Fundamental Date;
Container has one Fundamental Time;
Container has one Fundamental DateTime;
Container has one Fundamental Timestamp;
Container has one Fundamental Binary;
Container has one Alternate Bit;
Container has one Alternate Auto Counter;
Container has one Alternate Int;
Container has one Alternate Tiny Int;
Container has one Alternate Small Int;
Container has one Alternate Big Int;
Container has one Alternate Unsigned;
Container has one Alternate Unsigned Int;
Container has one Alternate Unsigned Integer;
Container has one Alternate Signed Int;
Container has one Alternate Signed Integer;
Container has one Alternate Float;
Container has one Alternate Double;
Container has one Alternate Currency;
Container has one Alternate Character;
Container has one Alternate Nchar;
Container has one Alternate National Character;
Container has one Alternate Fixed Length Text;
Container has one Alternate Varchar;
Container has one Alternate Nvarchar;
Container has one Alternate National Character Varying;
Container has one Alternate Variable Length Text;
Container has one Alternate Large Length Text;
Container has one Alternate Date Time;
Container has one Alternate Time Stamp;
Container has one Alternate Auto Time Stamp;
Container has one Alternate Guid;
Container has one Alternate Picture Raw Data;
Container has one Alternate Variable Length Raw Data;
Container has one Char8;
Container has one String255;
Container has one Text65536;
Container has one Byte;
Container has one Word;
Container has one Int;
Container has one Quad;
Container has one Large;
Container has one UByte;
Container has one UWord;
Container has one UInt;
Container has one UQuad;
Container has one ULarge;
Container has one Int8;
Container has one Int16;
Container has one Int32;
Container has one Int64;
Container has one Int80;
Container has one Real32;
Container has one Real64;
Container has one Real80;
Container has one Decimal8_3;
Container has one Decimal14;
Container has one Decimal14_6;

each AAC_ET is identified by Alternate Auto Counter where
    AAC_ET has one Alternate Auto Counter,
    Alternate Auto Counter is of at most one AAC_ET;

each AAC_Sub is a kind of AAC_ET [separate];

each AG_ET is identified by Alternate Guid where
    AG_ET has one Alternate Guid,
    Alternate Guid is of at most one AG_ET;

each AG_Sub is a kind of AG_ET [separate];
