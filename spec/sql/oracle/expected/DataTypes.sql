CREATE TABLE AAC_ET (
	-- AAC_ET has Alternate Auto Counter
	ALTERNATE_AUTO_COUNTER                  LONGINTEGER NOT NULL GENERATED BY DEFAULT ON NULL AS IDENTITY,
	-- Primary index to AAC_ET(Alternate Auto Counter in "AAC_ET has Alternate Auto Counter")
	PRIMARY KEY(ALTERNATE_AUTO_COUNTER)
);


CREATE TABLE AAC_SUB (
	-- AAC_Sub is a kind of AAC_ET that has Alternate Auto Counter
	AAC_ET_ALTERNATE_AUTO_COUNTER           LONGINTEGER NOT NULL,
	-- Primary index to AAC_Sub(AAC_ET in "AAC_Sub is a kind of AAC_ET")
	PRIMARY KEY(AAC_ET_ALTERNATE_AUTO_COUNTER),
	FOREIGN KEY (AAC_ET_ALTERNATE_AUTO_COUNTER) REFERENCES AAC_ET (ALTERNATE_AUTO_COUNTER)
);


CREATE TABLE AG_ET (
	-- AG_ET has Alternate Guid
	ALTERNATE_GUID                          RAW(16) NOT NULL DEFAULT SYS_GUID(),
	-- Primary index to AG_ET(Alternate Guid in "AG_ET has Alternate Guid")
	PRIMARY KEY(ALTERNATE_GUID)
);


CREATE TABLE AG_SUB (
	-- AG_Sub is a kind of AG_ET that has Alternate Guid
	AG_ET_ALTERNATE_GUID                    RAW(16) NOT NULL,
	-- Primary index to AG_Sub(AG_ET in "AG_Sub is a kind of AG_ET")
	PRIMARY KEY(AG_ET_ALTERNATE_GUID),
	FOREIGN KEY (AG_ET_ALTERNATE_GUID) REFERENCES AG_ET (ALTERNATE_GUID)
);


CREATE TABLE CONTAINER (
	-- Container has Container Name
	CONTAINER_NAME                          VARCHAR NOT NULL,
	-- Container has Alternate Auto Counter
	ALTERNATE_AUTO_COUNTER                  LONGINTEGER NOT NULL,
	-- Container has Alternate Auto Time Stamp
	ALTERNATE_AUTO_TIME_STAMP               DATETIME NOT NULL,
	-- Container has Alternate Big Int
	ALTERNATE_BIG_INT                       LONGINTEGER NOT NULL,
	-- Container has Alternate Bit
	ALTERNATE_BIT                           CHAR(1) NOT NULL,
	-- Container has Alternate Character
	ALTERNATE_CHARACTER                     VARCHAR NOT NULL,
	-- Container has Alternate Currency
	ALTERNATE_CURRENCY                      MONEY NOT NULL,
	-- Container has Alternate Date Time
	ALTERNATE_DATE_TIME                     DATETIME NOT NULL,
	-- Container has Alternate Double
	ALTERNATE_DOUBLE                        FLOAT NOT NULL,
	-- Container has Alternate Fixed Length Text
	ALTERNATE_FIXED_LENGTH_TEXT             VARCHAR NOT NULL,
	-- Container has Alternate Float
	ALTERNATE_FLOAT                         FLOAT NOT NULL,
	-- Container has Alternate Guid
	ALTERNATE_GUID                          RAW(16) NOT NULL,
	-- Container has Alternate Int
	ALTERNATE_INT                           INTEGER NOT NULL CHECK((ALTERNATE_INT >= -2147483648 AND ALTERNATE_INT <= 2147483647)),
	-- Container has Alternate Large Length Text
	ALTERNATE_LARGE_LENGTH_TEXT             VARCHAR(MAX) NOT NULL,
	-- Container has Alternate National Character
	ALTERNATE_NATIONAL_CHARACTER            VARCHAR NOT NULL,
	-- Container has Alternate National Character Varying
	ALTERNATE_NATIONAL_CHARACTER_VARYING    VARCHAR NOT NULL,
	-- Container has Alternate Nchar
	ALTERNATE_NCHAR                         VARCHAR NOT NULL,
	-- Container has Alternate Nvarchar
	ALTERNATE_NVARCHAR                      VARCHAR NOT NULL,
	-- Container has Alternate Picture Raw Data
	ALTERNATE_PICTURE_RAW_DATA              LOB NOT NULL,
	-- Container has Alternate Signed Int
	ALTERNATE_SIGNED_INT                    INTEGER NOT NULL,
	-- Container has Alternate Signed Integer
	ALTERNATE_SIGNED_INTEGER                INTEGER NOT NULL,
	-- Container has Alternate Small Int
	ALTERNATE_SMALL_INT                     SHORTINTEGER NOT NULL,
	-- Container has Alternate Time Stamp
	ALTERNATE_TIME_STAMP                    DATETIME NOT NULL,
	-- Container has Alternate Tiny Int
	ALTERNATE_TINY_INT                      SHORTINTEGER NOT NULL,
	-- Container has Alternate Unsigned
	ALTERNATE_UNSIGNED                      INTEGER NOT NULL,
	-- Container has Alternate Unsigned Int
	ALTERNATE_UNSIGNED_INT                  INTEGER NOT NULL,
	-- Container has Alternate Unsigned Integer
	ALTERNATE_UNSIGNED_INTEGER              INTEGER NOT NULL,
	-- Container has Alternate Varchar
	ALTERNATE_VARCHAR                       VARCHAR NOT NULL,
	-- Container has Alternate Variable Length Raw Data
	ALTERNATE_VARIABLE_LENGTH_RAW_DATA      LOB NOT NULL,
	-- Container has Alternate Variable Length Text
	ALTERNATE_VARIABLE_LENGTH_TEXT          VARCHAR NOT NULL,
	-- Container has Byte
	BYTE                                    SHORTINTEGER NOT NULL CHECK((BYTE >= -128 AND BYTE <= 127)),
	-- Container has Char8
	CHAR8                                   VARCHAR(8) NOT NULL,
	-- Container has Decimal14
	DECIMAL14                               DECIMAL(14) NOT NULL,
	-- Container has Decimal14_6
	DECIMAL14__6                            DECIMAL(14, 6) NOT NULL,
	-- Container has Decimal8_3
	DECIMAL8__3                             DECIMAL(8, 3) NOT NULL,
	-- Container has Fundamental Binary
	FUNDAMENTAL_BINARY                      LOB NOT NULL,
	-- Container has Fundamental Boolean
	FUNDAMENTAL_BOOLEAN                     CHAR(1) NOT NULL,
	-- Container has Fundamental Char
	FUNDAMENTAL_CHAR                        VARCHAR NOT NULL,
	-- Container has Fundamental Date
	FUNDAMENTAL_DATE                        DATE NOT NULL,
	-- Container has Fundamental DateTime
	FUNDAMENTAL_DATE_TIME                   DATETIME NOT NULL,
	-- Container has Fundamental Decimal
	FUNDAMENTAL_DECIMAL                     DECIMAL NOT NULL,
	-- Container has Fundamental Integer
	FUNDAMENTAL_INTEGER                     INTEGER NOT NULL,
	-- Container has Fundamental Money
	FUNDAMENTAL_MONEY                       MONEY NOT NULL,
	-- Container has Fundamental Real
	FUNDAMENTAL_REAL                        FLOAT NOT NULL,
	-- Container has Fundamental String
	FUNDAMENTAL_STRING                      VARCHAR NOT NULL,
	-- Container has Fundamental Text
	FUNDAMENTAL_TEXT                        VARCHAR(MAX) NOT NULL,
	-- Container has Fundamental Time
	FUNDAMENTAL_TIME                        TIME NOT NULL,
	-- Container has Fundamental Timestamp
	FUNDAMENTAL_TIMESTAMP                   DATETIME NOT NULL,
	-- Container has Int
	"INT"                                   INTEGER NOT NULL CHECK(("INT" >= -2147483648 AND "INT" <= 2147483647)),
	-- Container has Int16
	INT16                                   SHORTINTEGER NOT NULL,
	-- Container has Int32
	INT32                                   INTEGER NOT NULL,
	-- Container has Int64
	INT64                                   LONGINTEGER NOT NULL,
	-- Container has Int8
	INT8                                    SHORTINTEGER NOT NULL,
	-- Container has Int80
	INT80                                   Integer(80) NOT NULL,
	-- Container has Large
	"LARGE"                                 LONGINTEGER NOT NULL CHECK(("LARGE" >= -9223372036854775808999 AND "LARGE" <= 9223372036854775807999)),
	-- Container has Quad
	QUAD                                    LONGINTEGER NOT NULL CHECK((QUAD >= -9223372036854775808 AND QUAD <= 9223372036854775807)),
	-- Container has Real32
	REAL32                                  FLOAT(32) NOT NULL,
	-- Container has Real64
	REAL64                                  FLOAT(64) NOT NULL,
	-- Container has Real80
	REAL80                                  FLOAT(80) NOT NULL,
	-- Container has String255
	STRING255                               VARCHAR(255) NOT NULL,
	-- Container has Text65536
	TEXT65536                               VARCHAR(65536) NOT NULL,
	-- Container has UByte
	U_BYTE                                  SHORTINTEGER NOT NULL CHECK((U_BYTE >= 0 AND U_BYTE <= 255)),
	-- Container has UInt
	U_INT                                   LONGINTEGER NOT NULL CHECK((U_INT >= 0 AND U_INT <= 4294967295)),
	-- Container has ULarge
	U_LARGE                                 LONGINTEGER NOT NULL CHECK((U_LARGE >= 0 AND U_LARGE <= 184467440737095516159999)),
	-- Container has UQuad
	U_QUAD                                  LONGINTEGER NOT NULL CHECK((U_QUAD >= 0 AND U_QUAD <= 18446744073709551615)),
	-- Container has UWord
	U_WORD                                  INTEGER NOT NULL CHECK((U_WORD >= 0 AND U_WORD <= 65535)),
	-- Container has Word
	WORD                                    SHORTINTEGER NOT NULL CHECK((WORD >= -32768 AND WORD <= 32767)),
	-- Primary index to Container(Container Name in "Container has Container Name")
	PRIMARY KEY(CONTAINER_NAME)
);


