CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE base (
	-- Base has Base GUID
	base_guid                               UUID NOT NULL DEFAULT 'gen_random_uuid()',
	-- Base has base-Val
	base_val                                Val NOT NULL,
	-- Primary index to Base over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	PRIMARY KEY(base_guid)
);


CREATE TABLE "partition" (
	-- Partition is a kind of Base that has Base GUID
	base_guid                               UUID NOT NULL DEFAULT 'gen_random_uuid()',
	-- Partition is a kind of Base that has base-Val
	base_val                                Val NOT NULL,
	-- Partition has part-Val
	part_val                                Val NOT NULL,
	-- Primary index to Partition over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	PRIMARY KEY(base_guid)
);


CREATE TABLE partition_ind (
	-- PartitionInd surrogate key
	partition_ind_id                        BIGSERIAL NOT NULL,
	-- PartitionInd is a kind of Base that has Base GUID
	base_guid                               UUID NOT NULL,
	-- PartitionInd is a kind of Base that has base-Val
	base_val                                Val NOT NULL,
	-- PartitionInd has PartitionInd Key
	partition_ind_key                       UUID NOT NULL,
	-- maybe PartitionInd is an AbsorbedPart that has abs- part Val
	absorbed_part_abs_part_val              Val NULL,
	-- Primary index to PartitionInd
	PRIMARY KEY(partition_ind_id),
	-- Unique index to PartitionInd over PresenceConstraint over (Base GUID in "Base has Base GUID") occurs at most one time
	UNIQUE(base_guid),
	-- Unique index to PartitionInd over PresenceConstraint over (PartitionInd Key in "PartitionInd has PartitionInd Key") occurs at most one time
	UNIQUE(partition_ind_key)
);


CREATE TABLE separate (
	-- Separate is a kind of Base that has Base GUID
	base_guid                               UUID NOT NULL,
	-- Separate has sep-Val
	sep_val                                 Val NOT NULL,
	-- Primary index to Separate over PresenceConstraint over (Base in "Separate is a kind of Base") occurs at most one time
	PRIMARY KEY(base_guid),
	FOREIGN KEY (base_guid) REFERENCES base (base_guid)
);


