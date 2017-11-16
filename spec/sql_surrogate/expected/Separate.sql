CREATE TABLE Base (
	-- Base has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Base has base-Val
	BaseVal                                 Val NOT NULL,
	-- Primary index to Base over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	PRIMARY KEY(BaseGUID)
);


CREATE TABLE "Partition" (
	-- Partition is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Partition is a kind of Base that has base-Val
	BaseVal                                 Val NOT NULL,
	-- Partition has part-Val
	PartVal                                 Val NOT NULL,
	-- Primary index to Partition over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	PRIMARY KEY(BaseGUID)
);


CREATE TABLE PartitionInd (
	-- PartitionInd surrogate key
	PartitionIndID                          BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- PartitionInd is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- PartitionInd is a kind of Base that has base-Val
	BaseVal                                 Val NOT NULL,
	-- PartitionInd has PartitionInd Key
	PartitionIndKey                         BINARY(16) NOT NULL,
	-- maybe PartitionInd is an AbsorbedPart that has abs- part Val
	AbsorbedPartAbsPartVal                  Val NULL,
	-- Primary index to PartitionInd
	PRIMARY KEY(PartitionIndID),
	-- Unique index to PartitionInd over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	UNIQUE(BaseGUID),
	-- Unique index to PartitionInd over PresenceConstraint over (PartitionInd Key in "PartitionInd has PartitionInd Key") occurs at most one time
	UNIQUE(PartitionIndKey)
);


CREATE TABLE Separate (
	-- Separate is a kind of Base that has Base GUID
	BaseGUID                                BINARY(16) NOT NULL,
	-- Separate has sep-Val
	SepVal                                  Val NOT NULL,
	-- Primary index to Separate over PresenceConstraint over (Base in "Separate is a kind of Base") occurs at most one time
	PRIMARY KEY(BaseGUID),
	FOREIGN KEY (BaseGUID) REFERENCES Base (BaseGUID)
);


