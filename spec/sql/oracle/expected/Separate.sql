CREATE TABLE BASE (
	-- Base has Base GUID
	BASE_GUID                               RAW(32) NOT NULL DEFAULT SYS_GUID(),
	-- Base has base-Val
	BASE_VAL                                Val NOT NULL,
	-- Primary index to Base over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	PRIMARY KEY(BASE_GUID)
);


CREATE TABLE "PARTITION" (
	-- Partition is a kind of Base that has Base GUID
	BASE_GUID                               RAW(32) NOT NULL,
	-- Partition is a kind of Base that has base-Val
	BASE_VAL                                Val NOT NULL,
	-- Partition has part-Val
	PART_VAL                                Val NOT NULL,
	-- Unique index to Partition over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	UNIQUE(BASE_GUID)
);


CREATE TABLE PARTITION_IND (
	-- PartitionInd is a kind of Base that has Base GUID
	BASE_GUID                               RAW(32) NOT NULL,
	-- PartitionInd is a kind of Base that has base-Val
	BASE_VAL                                Val NOT NULL,
	-- PartitionInd has PartitionInd Key
	PARTITION_IND_KEY                       RAW(32) NOT NULL DEFAULT SYS_GUID(),
	-- maybe PartitionInd is an AbsorbedPart that has abs- part Val
	ABSORBED_PART_ABS_PART_VAL              Val NULL,
	-- Primary index to PartitionInd over PresenceConstraint over (PartitionInd Key in "PartitionInd has PartitionInd Key") occurs at most one time
	PRIMARY KEY(PARTITION_IND_KEY),
	-- Unique index to PartitionInd over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	UNIQUE(BASE_GUID)
);


CREATE TABLE SEPARATE (
	-- Separate is a kind of Base that has Base GUID
	BASE_GUID                               RAW(32) NOT NULL,
	-- Separate has sep-Val
	SEP_VAL                                 Val NOT NULL,
	-- Primary index to Separate over PresenceConstraint over (Base in "Separate is a kind of Base") occurs at most one time
	PRIMARY KEY(BASE_GUID),
	FOREIGN KEY (BASE_GUID) REFERENCES BASE (BASE_GUID)
);


