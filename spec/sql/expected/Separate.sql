CREATE TABLE Base (
	-- Base has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Base has base-Val
	BaseVal                                 Val NOT NULL,
	-- Primary index to Base(Base GUID in "Base has Base GUID")
	PRIMARY KEY(BaseGUID)
);


CREATE TABLE "Partition" (
	-- Partition is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Partition is a kind of Base that has base-Val
	BaseVal                                 Val NOT NULL,
	-- Partition has part-Val
	PartVal                                 Val NOT NULL,
	-- Primary index to Partition(Base GUID in "Base has Base GUID")
	PRIMARY KEY(BaseGUID)
);


CREATE TABLE PartitionInd (
	-- PartitionInd is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- PartitionInd is a kind of Base that has base-Val
	BaseVal                                 Val NOT NULL,
	-- PartitionInd has PartitionInd Key
	PartitionIndKey                         BINARY(16) NOT NULL,
	-- maybe PartitionInd is an AbsorbedPart that has abs- part Val
	AbsorbedPartAbsPartVal                  Val NULL,
	-- Primary index to PartitionInd(PartitionInd Key in "PartitionInd has PartitionInd Key")
	PRIMARY KEY(PartitionIndKey),
	-- Unique index to PartitionInd(Base GUID in "Base has Base GUID")
	UNIQUE(BaseGUID)
);


CREATE TABLE Separate (
	-- Separate is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Separate has sep-Val
	SepVal                                  Val NOT NULL,
	-- Primary index to Separate(Base in "Separate is a kind of Base")
	PRIMARY KEY(BaseGUID),
	FOREIGN KEY (BaseGUID) REFERENCES Base (BaseGUID)
);


