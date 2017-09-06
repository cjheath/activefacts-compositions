CREATE TABLE AAC_ET (
	-- AAC_ET has Alternate Auto Counter
	AlternateAutoCounter                    BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to AAC_ET over PresenceConstraint over (Alternate Auto Counter in "AAC_ET has Alternate Auto Counter") occurs at most one time
	PRIMARY KEY CLUSTERED(AlternateAutoCounter)
);


CREATE TABLE AG_ET (
	-- AG_ET has Alternate Guid
	AlternateGuid                           BINARY(16) NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to AG_ET over PresenceConstraint over (Alternate Guid in "AG_ET has Alternate Guid") occurs at most one time
	PRIMARY KEY CLUSTERED(AlternateGuid)
);


CREATE TABLE Container (
	-- Container has Container Name
	ContainerName                           VARCHAR NOT NULL,
	-- Container has Alternate Auto Counter
	AlternateAutoCounter                    BIGINT NOT NULL,
	-- Container has Alternate Auto Time Stamp
	AlternateAutoTimeStamp                  TIMESTAMP NOT NULL,
	-- Container has Alternate Big Int
	AlternateBigInt                         BIGINT NOT NULL,
	-- Container has Alternate Bit
	AlternateBit                            BOOLEAN NOT NULL,
	-- Container has Alternate Character
	AlternateCharacter                      CHARACTER NOT NULL,
	-- Container has Alternate Currency
	AlternateCurrency                       DECIMAL NOT NULL,
	-- Container has Alternate Date Time
	AlternateDateTime                       TIMESTAMP NOT NULL,
	-- Container has Alternate Double
	AlternateDouble                         FLOAT(53) NOT NULL,
	-- Container has Alternate Fixed Length Text
	AlternateFixedLengthText                CHARACTER NOT NULL,
	-- Container has Alternate Float
	AlternateFloat                          FLOAT(53) NOT NULL,
	-- Container has Alternate Guid
	AlternateGuid                           BINARY(16) NOT NULL,
	-- Container has Alternate Int
	AlternateInt                            INTEGER NOT NULL CHECK((AlternateInt >= -2147483648 AND AlternateInt <= 2147483647)),
	-- Container has Alternate Large Length Text
	AlternateLargeLengthText                VARCHAR(MAX) NOT NULL,
	-- Container has Alternate National Character
	AlternateNationalCharacter              CHARACTER NOT NULL,
	-- Container has Alternate National Character Varying
	AlternateNationalCharacterVarying       VARCHAR NOT NULL,
	-- Container has Alternate Nchar
	AlternateNchar                          CHARACTER NOT NULL,
	-- Container has Alternate Nvarchar
	AlternateNvarchar                       VARCHAR NOT NULL,
	-- Container has Alternate Picture Raw Data
	AlternatePictureRawData                 VARBINARY NOT NULL,
	-- Container has Alternate Signed Int
	AlternateSignedInt                      INTEGER NOT NULL,
	-- Container has Alternate Signed Integer
	AlternateSignedInteger                  INTEGER NOT NULL,
	-- Container has Alternate Small Int
	AlternateSmallInt                       SMALLINT NOT NULL,
	-- Container has Alternate Time Stamp
	AlternateTimeStamp                      TIMESTAMP NOT NULL,
	-- Container has Alternate Tiny Int
	AlternateTinyInt                        SMALLINT NOT NULL,
	-- Container has Alternate Unsigned
	AlternateUnsigned                       INTEGER NOT NULL,
	-- Container has Alternate Unsigned Int
	AlternateUnsignedInt                    INTEGER NOT NULL,
	-- Container has Alternate Unsigned Integer
	AlternateUnsignedInteger                INTEGER NOT NULL,
	-- Container has Alternate Varchar
	AlternateVarchar                        VARCHAR NOT NULL,
	-- Container has Alternate Variable Length Raw Data
	AlternateVariableLengthRawData          VARBINARY NOT NULL,
	-- Container has Alternate Variable Length Text
	AlternateVariableLengthText             VARCHAR NOT NULL,
	-- Container has Byte
	Byte                                    SMALLINT NOT NULL CHECK((Byte >= -128 AND Byte <= 127)),
	-- Container has Char8
	Char8                                   CHARACTER(8) NOT NULL,
	-- Container has Decimal14
	Decimal14                               DECIMAL NOT NULL,
	-- Container has Decimal14_6
	Decimal14_6                             DECIMAL NOT NULL,
	-- Container has Decimal8_3
	Decimal8_3                              DECIMAL NOT NULL,
	-- Container has Fundamental Binary
	FundamentalBinary                       VARBINARY NOT NULL,
	-- Container has Fundamental Boolean
	FundamentalBoolean                      BOOLEAN NOT NULL,
	-- Container has Fundamental Char
	FundamentalChar                         CHARACTER NOT NULL,
	-- Container has Fundamental Date
	FundamentalDate                         DATE NOT NULL,
	-- Container has Fundamental DateTime
	FundamentalDateTime                     TIMESTAMP NOT NULL,
	-- Container has Fundamental Decimal
	FundamentalDecimal                      DECIMAL NOT NULL,
	-- Container has Fundamental Integer
	FundamentalInteger                      INTEGER NOT NULL,
	-- Container has Fundamental Money
	FundamentalMoney                        DECIMAL NOT NULL,
	-- Container has Fundamental Real
	FundamentalReal                         FLOAT(53) NOT NULL,
	-- Container has Fundamental String
	FundamentalString                       VARCHAR NOT NULL,
	-- Container has Fundamental Text
	FundamentalText                         VARCHAR(MAX) NOT NULL,
	-- Container has Fundamental Time
	FundamentalTime                         TIME NOT NULL,
	-- Container has Fundamental Timestamp
	FundamentalTimestamp                    TIMESTAMP NOT NULL,
	-- Container has Int
	[Int]                                   INTEGER NOT NULL CHECK(([Int] >= -2147483648 AND [Int] <= 2147483647)),
	-- Container has Int16
	Int16                                   SMALLINT NOT NULL,
	-- Container has Int32
	Int32                                   INTEGER NOT NULL,
	-- Container has Int64
	Int64                                   BIGINT NOT NULL,
	-- Container has Int8
	Int8                                    SMALLINT NOT NULL,
	-- Container has Int80
	Int80                                   int NOT NULL,
	-- Container has Large
	[Large]                                 BIGINT NOT NULL CHECK(([Large] >= -9223372036854775808999 AND [Large] <= 9223372036854775807999)),
	-- Container has Quad
	Quad                                    BIGINT NOT NULL CHECK((Quad >= -9223372036854775808 AND Quad <= 9223372036854775807)),
	-- Container has Real32
	Real32                                  FLOAT(53) NOT NULL,
	-- Container has Real64
	Real64                                  FLOAT(53) NOT NULL,
	-- Container has Real80
	Real80                                  FLOAT(53) NOT NULL,
	-- Container has String255
	String255                               VARCHAR(255) NOT NULL,
	-- Container has Text65536
	Text65536                               VARCHAR(65536) NOT NULL,
	-- Container has UByte
	UByte                                   SMALLINT NOT NULL CHECK((UByte >= 0 AND UByte <= 255)),
	-- Container has UInt
	UInt                                    BIGINT NOT NULL CHECK((UInt >= 0 AND UInt <= 4294967295)),
	-- Container has ULarge
	ULarge                                  BIGINT NOT NULL CHECK((ULarge >= 0 AND ULarge <= 184467440737095516159999)),
	-- Container has UQuad
	UQuad                                   BIGINT NOT NULL CHECK((UQuad >= 0 AND UQuad <= 18446744073709551615)),
	-- Container has UWord
	UWord                                   INTEGER NOT NULL CHECK((UWord >= 0 AND UWord <= 65535)),
	-- Container has Word
	Word                                    SMALLINT NOT NULL CHECK((Word >= -32768 AND Word <= 32767)),
	-- Primary index to Container over PresenceConstraint over (Container Name in "Container has Container Name") occurs at most one time
	PRIMARY KEY CLUSTERED(ContainerName)
);


