CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;

CREATE TABLE aac_et (
	-- AAC_ET has Alternate Auto Counter
	alternate_auto_counter                  BIGSERIAL NOT NULL,
	-- Primary index to AAC_ET(Alternate Auto Counter in "AAC_ET has Alternate Auto Counter")
	PRIMARY KEY(alternate_auto_counter)
);


CREATE TABLE aac_sub (
	-- AAC_Sub is a kind of AAC_ET that has Alternate Auto Counter
	aac_et_alternate_auto_counter           BIGINT NOT NULL,
	-- Primary index to AAC_Sub(AAC_ET in "AAC_Sub is a kind of AAC_ET")
	PRIMARY KEY(aac_et_alternate_auto_counter),
	FOREIGN KEY (aac_et_alternate_auto_counter) REFERENCES aac_et (alternate_auto_counter)
);


CREATE TABLE ag_et (
	-- AG_ET has Alternate Guid
	alternate_guid                          UUID NOT NULL DEFAULT gen_random_uuid(),
	-- Primary index to AG_ET(Alternate Guid in "AG_ET has Alternate Guid")
	PRIMARY KEY(alternate_guid)
);


CREATE TABLE ag_sub (
	-- AG_Sub is a kind of AG_ET that has Alternate Guid
	ag_et_alternate_guid                    UUID NOT NULL,
	-- Primary index to AG_Sub(AG_ET in "AG_Sub is a kind of AG_ET")
	PRIMARY KEY(ag_et_alternate_guid),
	FOREIGN KEY (ag_et_alternate_guid) REFERENCES ag_et (alternate_guid)
);


CREATE TABLE container (
	-- Container has Container Name
	container_name                          VARCHAR NOT NULL,
	-- Container has Alternate Auto Counter
	alternate_auto_counter                  BIGINT NOT NULL,
	-- Container has Alternate Auto Time Stamp
	alternate_auto_time_stamp               TIMESTAMP NOT NULL,
	-- Container has Alternate Big Int
	alternate_big_int                       BIGINT NOT NULL,
	-- Container has Alternate Bit
	alternate_bit                           BOOLEAN NOT NULL,
	-- Container has Alternate Character
	alternate_character                     VARCHAR NOT NULL,
	-- Container has Alternate Currency
	alternate_currency                      MONEY NOT NULL,
	-- Container has Alternate Date Time
	alternate_date_time                     TIMESTAMP NOT NULL,
	-- Container has Alternate Double
	alternate_double                        FLOAT NOT NULL,
	-- Container has Alternate Fixed Length Text
	alternate_fixed_length_text             VARCHAR NOT NULL,
	-- Container has Alternate Float
	alternate_float                         FLOAT NOT NULL,
	-- Container has Alternate Guid
	alternate_guid                          UUID NOT NULL,
	-- Container has Alternate Int
	alternate_int                           INTEGER NOT NULL CHECK((alternate_int >= -2147483648 AND alternate_int <= 2147483647)),
	-- Container has Alternate Large Length Text
	alternate_large_length_text             VARCHAR(MAX) NOT NULL,
	-- Container has Alternate National Character
	alternate_national_character            VARCHAR NOT NULL,
	-- Container has Alternate National Character Varying
	alternate_national_character_varying    VARCHAR NOT NULL,
	-- Container has Alternate Nchar
	alternate_nchar                         VARCHAR NOT NULL,
	-- Container has Alternate Nvarchar
	alternate_nvarchar                      VARCHAR NOT NULL,
	-- Container has Alternate Picture Raw Data
	alternate_picture_raw_data              BYTEA NOT NULL,
	-- Container has Alternate Signed Int
	alternate_signed_int                    INTEGER NOT NULL,
	-- Container has Alternate Signed Integer
	alternate_signed_integer                INTEGER NOT NULL,
	-- Container has Alternate Small Int
	alternate_small_int                     SMALLINT NOT NULL,
	-- Container has Alternate Time Stamp
	alternate_time_stamp                    TIMESTAMP NOT NULL,
	-- Container has Alternate Tiny Int
	alternate_tiny_int                      SMALLINT NOT NULL,
	-- Container has Alternate Unsigned
	alternate_unsigned                      INTEGER NOT NULL,
	-- Container has Alternate Unsigned Int
	alternate_unsigned_int                  INTEGER NOT NULL,
	-- Container has Alternate Unsigned Integer
	alternate_unsigned_integer              INTEGER NOT NULL,
	-- Container has Alternate Varchar
	alternate_varchar                       VARCHAR NOT NULL,
	-- Container has Alternate Variable Length Raw Data
	alternate_variable_length_raw_data      BYTEA NOT NULL,
	-- Container has Alternate Variable Length Text
	alternate_variable_length_text          VARCHAR NOT NULL,
	-- Container has Byte
	byte                                    SMALLINT NOT NULL CHECK((byte >= -128 AND byte <= 127)),
	-- Container has Char8
	char8                                   VARCHAR(8) NOT NULL,
	-- Container has Decimal14
	decimal14                               DECIMAL(14) NOT NULL,
	-- Container has Decimal14_6
	decimal14__6                            DECIMAL(14, 6) NOT NULL,
	-- Container has Decimal8_3
	decimal8__3                             DECIMAL(8, 3) NOT NULL,
	-- Container has Fundamental Binary
	fundamental_binary                      BYTEA NOT NULL,
	-- Container has Fundamental Boolean
	fundamental_boolean                     BOOLEAN NOT NULL,
	-- Container has Fundamental Char
	fundamental_char                        VARCHAR NOT NULL,
	-- Container has Fundamental Date
	fundamental_date                        DATE NOT NULL,
	-- Container has Fundamental DateTime
	fundamental_date_time                   TIMESTAMP NOT NULL,
	-- Container has Fundamental Decimal
	fundamental_decimal                     DECIMAL NOT NULL,
	-- Container has Fundamental Integer
	fundamental_integer                     INTEGER NOT NULL,
	-- Container has Fundamental Money
	fundamental_money                       MONEY NOT NULL,
	-- Container has Fundamental Real
	fundamental_real                        FLOAT NOT NULL,
	-- Container has Fundamental String
	fundamental_string                      VARCHAR NOT NULL,
	-- Container has Fundamental Text
	fundamental_text                        VARCHAR(MAX) NOT NULL,
	-- Container has Fundamental Time
	fundamental_time                        TIME NOT NULL,
	-- Container has Fundamental Timestamp
	fundamental_timestamp                   TIMESTAMP NOT NULL,
	-- Container has Int
	"int"                                   INTEGER NOT NULL CHECK(("int" >= -2147483648 AND "int" <= 2147483647)),
	-- Container has Int16
	int16                                   SMALLINT NOT NULL,
	-- Container has Int32
	int32                                   INTEGER NOT NULL,
	-- Container has Int64
	int64                                   BIGINT NOT NULL,
	-- Container has Int8
	int8                                    SMALLINT NOT NULL,
	-- Container has Int80
	int80                                   Integer(80) NOT NULL,
	-- Container has Large
	"large"                                 BIGINT NOT NULL CHECK(("large" >= -9223372036854775808999 AND "large" <= 9223372036854775807999)),
	-- Container has Quad
	quad                                    BIGINT NOT NULL CHECK((quad >= -9223372036854775808 AND quad <= 9223372036854775807)),
	-- Container has Real32
	real32                                  FLOAT(32) NOT NULL,
	-- Container has Real64
	real64                                  FLOAT(64) NOT NULL,
	-- Container has Real80
	real80                                  FLOAT(80) NOT NULL,
	-- Container has String255
	string255                               VARCHAR(255) NOT NULL,
	-- Container has Text65536
	text65536                               VARCHAR(65536) NOT NULL,
	-- Container has UByte
	u_byte                                  SMALLINT NOT NULL CHECK((u_byte >= 0 AND u_byte <= 255)),
	-- Container has UInt
	u_int                                   BIGINT NOT NULL CHECK((u_int >= 0 AND u_int <= 4294967295)),
	-- Container has ULarge
	u_large                                 BIGINT NOT NULL CHECK((u_large >= 0 AND u_large <= 184467440737095516159999)),
	-- Container has UQuad
	u_quad                                  BIGINT NOT NULL CHECK((u_quad >= 0 AND u_quad <= 18446744073709551615)),
	-- Container has UWord
	u_word                                  INTEGER NOT NULL CHECK((u_word >= 0 AND u_word <= 65535)),
	-- Container has Word
	word                                    SMALLINT NOT NULL CHECK((word >= -32768 AND word <= 32767)),
	-- Primary index to Container(Container Name in "Container has Container Name")
	PRIMARY KEY(container_name)
);


