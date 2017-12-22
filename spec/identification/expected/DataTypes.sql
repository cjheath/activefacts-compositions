CREATE TABLE AACET (
	-- AAC_ET has Alternate Auto Counter
	AlternateAutoCounter                    BIGINT NOT NULL IDENTITY,
	-- Primary index to AAC_ET(Alternate Auto Counter in "AAC_ET has Alternate Auto Counter")
	PRIMARY KEY CLUSTERED(AlternateAutoCounter)
)
GO


CREATE TABLE AACSub (
	-- AAC_Sub is a kind of AAC_ET that has Alternate Auto Counter
	AACETAlternateAutoCounter               BIGINT NOT NULL,
	-- Primary index to AAC_Sub(AAC_ET in "AAC_Sub is a kind of AAC_ET")
	PRIMARY KEY CLUSTERED(AACETAlternateAutoCounter),
	FOREIGN KEY (AACETAlternateAutoCounter) REFERENCES AACET (AlternateAutoCounter)
)
GO


CREATE TABLE AGET (
	-- AG_ET has Alternate Guid
	AlternateGuid                           UNIQUEIDENTIFIER(16) NOT NULL DEFAULT NEWID(),
	-- Primary index to AG_ET(Alternate Guid in "AG_ET has Alternate Guid")
	PRIMARY KEY CLUSTERED(AlternateGuid)
)
GO


CREATE TABLE AGSub (
	-- AG_Sub is a kind of AG_ET that has Alternate Guid
	AGETAlternateGuid                       UNIQUEIDENTIFIER(16) NOT NULL,
	-- Primary index to AG_Sub(AG_ET in "AG_Sub is a kind of AG_ET")
	PRIMARY KEY CLUSTERED(AGETAlternateGuid),
	FOREIGN KEY (AGETAlternateGuid) REFERENCES AGET (AlternateGuid)
)
GO


CREATE TABLE Container (
	-- Container has Container Name
	ContainerName                           VARCHAR NOT NULL,
	-- Container has Alternate Auto Counter
	AlternateAutoCounter                    BIGINT NOT NULL,
	-- Container has Alternate Auto Time Stamp
	AlternateAutoTimeStamp                  DATETIME NOT NULL,
	-- Container has Alternate Big Int
	AlternateBigInt                         BIGINT NOT NULL,
	-- Container has Alternate Bit
	AlternateBit                            BIT NOT NULL,
	-- Container has Alternate Character
	AlternateCharacter                      CHAR NOT NULL,
	-- Container has Alternate Currency
	AlternateCurrency                       MONEY NOT NULL,
	-- Container has Alternate Date Time
	AlternateDateTime                       DATETIME NOT NULL,
	-- Container has Alternate Double
	AlternateDouble                         FLOAT NOT NULL,
	-- Container has Alternate Fixed Length Text
	AlternateFixedLengthText                CHAR NOT NULL,
	-- Container has Alternate Float
	AlternateFloat                          FLOAT NOT NULL,
	-- Container has Alternate Guid
	AlternateGuid                           UNIQUEIDENTIFIER(16) NOT NULL,
	-- Container has Alternate Int
	AlternateInt                            INTEGER NOT NULL CHECK((AlternateInt >= -2147483648 AND AlternateInt <= 2147483647)),
	-- Container has Alternate Large Length Text
	AlternateLargeLengthText                VARCHAR(MAX) NOT NULL,
	-- Container has Alternate National Character
	AlternateNationalCharacter              CHAR NOT NULL,
	-- Container has Alternate National Character Varying
	AlternateNationalCharacterVarying       VARCHAR NOT NULL,
	-- Container has Alternate Nchar
	AlternateNchar                          CHAR NOT NULL,
	-- Container has Alternate Nvarchar
	AlternateNvarchar                       VARCHAR NOT NULL,
	-- Container has Alternate Picture Raw Data
	AlternatePictureRawData                 IMAGE NOT NULL,
	-- Container has Alternate Signed Int
	AlternateSignedInt                      INTEGER NOT NULL,
	-- Container has Alternate Signed Integer
	AlternateSignedInteger                  INTEGER NOT NULL,
	-- Container has Alternate Small Int
	AlternateSmallInt                       SMALLINT NOT NULL,
	-- Container has Alternate Time Stamp
	AlternateTimeStamp                      DATETIME NOT NULL,
	-- Container has Alternate Tiny Int
	AlternateTinyInt                        TINYINT NOT NULL,
	-- Container has Alternate Unsigned
	AlternateUnsigned                       INTEGER NOT NULL,
	-- Container has Alternate Unsigned Int
	AlternateUnsignedInt                    INTEGER NOT NULL,
	-- Container has Alternate Unsigned Integer
	AlternateUnsignedInteger                INTEGER NOT NULL,
	-- Container has Alternate Varchar
	AlternateVarchar                        VARCHAR NOT NULL,
	-- Container has Alternate Variable Length Raw Data
	AlternateVariableLengthRawData          IMAGE NOT NULL,
	-- Container has Alternate Variable Length Text
	AlternateVariableLengthText             VARCHAR NOT NULL,
	-- Container has Byte
	Byte                                    TINYINT NOT NULL CHECK((Byte >= -128 AND Byte <= 127)),
	-- Container has Char8
	Char8                                   CHAR(8) NOT NULL,
	-- Container has Decimal14
	Decimal14                               DECIMAL(14) NOT NULL,
	-- Container has Decimal14_6
	Decimal14_6                             DECIMAL(14, 6) NOT NULL,
	-- Container has Decimal8_3
	Decimal8_3                              DECIMAL(8, 3) NOT NULL,
	-- Container has Fundamental Binary
	FundamentalBinary                       IMAGE NOT NULL,
	-- Container has Fundamental Boolean
	FundamentalBoolean                      BIT NOT NULL,
	-- Container has Fundamental Char
	FundamentalChar                         CHAR NOT NULL,
	-- Container has Fundamental Date
	FundamentalDate                         DATE NOT NULL,
	-- Container has Fundamental DateTime
	FundamentalDateTime                     DATETIME NOT NULL,
	-- Container has Fundamental Decimal
	FundamentalDecimal                      DECIMAL NOT NULL,
	-- Container has Fundamental Integer
	FundamentalInteger                      INTEGER NOT NULL,
	-- Container has Fundamental Money
	FundamentalMoney                        MONEY NOT NULL,
	-- Container has Fundamental Real
	FundamentalReal                         FLOAT NOT NULL,
	-- Container has Fundamental String
	FundamentalString                       VARCHAR NOT NULL,
	-- Container has Fundamental Text
	FundamentalText                         VARCHAR(MAX) NOT NULL,
	-- Container has Fundamental Time
	FundamentalTime                         TIME NOT NULL,
	-- Container has Fundamental Timestamp
	FundamentalTimestamp                    DATETIME NOT NULL,
	-- Container has Int
	[Int]                                   INTEGER NOT NULL CHECK(([Int] >= -2147483648 AND [Int] <= 2147483647)),
	-- Container has Int16
	Int16                                   SMALLINT NOT NULL,
	-- Container has Int32
	Int32                                   INTEGER NOT NULL,
	-- Container has Int64
	Int64                                   BIGINT NOT NULL,
	-- Container has Int8
	Int8                                    TINYINT NOT NULL,
	-- Container has Int80
	Int80                                   Integer(80) NOT NULL,
	-- Container has Large
	[Large]                                 BIGINT NOT NULL CHECK(([Large] >= -9223372036854775808999 AND [Large] <= 9223372036854775807999)),
	-- Container has Quad
	Quad                                    BIGINT NOT NULL CHECK((Quad >= -9223372036854775808 AND Quad <= 9223372036854775807)),
	-- Container has Real32
	Real32                                  FLOAT(32) NOT NULL,
	-- Container has Real64
	Real64                                  FLOAT(64) NOT NULL,
	-- Container has Real80
	Real80                                  FLOAT(80) NOT NULL,
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
	-- Primary index to Container(Container Name in "Container has Container Name")
	PRIMARY KEY CLUSTERED(ContainerName)
)
GO


