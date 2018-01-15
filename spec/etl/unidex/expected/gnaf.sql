CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;



/*
 * View to extract unified index values for address_detail
 */
CREATE OR REPLACE VIEW address_detail_unidex AS
SELECT  'phonetic' AS processing,
        dmetaphone(building_name) AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Building Name' AS source
FROM    address_detail
WHERE   COALESCE(dmetaphone(building_name),'') <> ''
UNION ALL
SELECT * FROM (
SELECT  'phonetic' AS processing,
        CASE WHEN dmetaphone(building_name) <> dmetaphone_alt(building_name) THEN dmetaphone_alt(building_name) ELSE NULL END AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Building Name' AS source
FROM    address_detail
WHERE   COALESCE(CASE WHEN dmetaphone(building_name) <> dmetaphone_alt(building_name) THEN dmetaphone_alt(building_name) ELSE NULL END,'') <> ''
) AS s WHERE Value IS NOT NULL
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(flat_number, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Flat Number' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(flat_number, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(flat_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Flat Number Prefix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(flat_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(flat_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Flat Number Suffix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(flat_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Flat Type Name' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(legal_parcel_id, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Legal Parcel Id' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(legal_parcel_id, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(level_number, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Level Number' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(level_number, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(level_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Level Number Prefix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(level_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(level_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Level Number Suffix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(level_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Level Type Name' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(lot_number, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Lot Number' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(lot_number, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(lot_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Lot Number Prefix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(lot_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(lot_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Lot Number Suffix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(lot_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_first, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number First' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_first, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_first_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number First Prefix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_first_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_first_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number First Suffix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_first_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_last, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number Last' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_last, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_last_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number Last Prefix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_last_prefix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(number_last_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Number Last Suffix' AS source
FROM    address_detail
WHERE   COALESCE(substring(btrim(lower(regexp_replace(number_last_suffix, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'simple' AS processing,
        substring(postcode for 32) AS value,
        load_batch_id,
        1.00 AS confidence,
        record_guid,
        'Postcode' AS source
FROM    address_detail
WHERE   COALESCE(substring(postcode for 32),'') <> '';



/*
 * View to extract unified index values for locality
 */
CREATE OR REPLACE VIEW locality_unidex AS
SELECT  'phonetic' AS processing,
        dmetaphone(locality_name) AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Locality Name' AS source
FROM    locality
WHERE   COALESCE(dmetaphone(locality_name),'') <> ''
UNION ALL
SELECT * FROM (
SELECT  'phonetic' AS processing,
        CASE WHEN dmetaphone(locality_name) <> dmetaphone_alt(locality_name) THEN dmetaphone_alt(locality_name) ELSE NULL END AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Locality Name' AS source
FROM    locality
WHERE   COALESCE(CASE WHEN dmetaphone(locality_name) <> dmetaphone_alt(locality_name) THEN dmetaphone_alt(locality_name) ELSE NULL END,'') <> ''
) AS s WHERE Value IS NOT NULL
UNION ALL
SELECT  'simple' AS processing,
        substring(primary_postcode for 32) AS value,
        load_batch_id,
        1.00 AS confidence,
        record_guid,
        'Primary Postcode' AS source
FROM    locality
WHERE   COALESCE(substring(primary_postcode for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'State Name' AS source
FROM    locality
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> '';

/*
 * View to extract unified index values for locality_alias
 */
CREATE OR REPLACE VIEW locality_alias_unidex AS
SELECT  'phonetic' AS processing,
        dmetaphone(name) AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Name' AS source
FROM    locality_alias
WHERE   COALESCE(dmetaphone(name),'') <> ''
UNION ALL
SELECT * FROM (
SELECT  'phonetic' AS processing,
        CASE WHEN dmetaphone(name) <> dmetaphone_alt(name) THEN dmetaphone_alt(name) ELSE NULL END AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Name' AS source
FROM    locality_alias
WHERE   COALESCE(CASE WHEN dmetaphone(name) <> dmetaphone_alt(name) THEN dmetaphone_alt(name) ELSE NULL END,'') <> ''
) AS s WHERE Value IS NOT NULL
UNION ALL
SELECT  'simple' AS processing,
        substring(postcode for 32) AS value,
        load_batch_id,
        1.00 AS confidence,
        record_guid,
        'Postcode' AS source
FROM    locality_alias
WHERE   COALESCE(substring(postcode for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'State Name' AS source
FROM    locality_alias
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> '';



/*
 * View to extract unified index values for street_locality
 */
CREATE OR REPLACE VIEW street_locality_unidex AS
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality
WHERE   COALESCE(substring(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'phonetic' AS processing,
        dmetaphone(street_name) AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality
WHERE   COALESCE(dmetaphone(street_name),'') <> ''
UNION ALL
SELECT * FROM (
SELECT  'phonetic' AS processing,
        CASE WHEN dmetaphone(street_name) <> dmetaphone_alt(street_name) THEN dmetaphone_alt(street_name) ELSE NULL END AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality
WHERE   COALESCE(CASE WHEN dmetaphone(street_name) <> dmetaphone_alt(street_name) THEN dmetaphone_alt(street_name) ELSE NULL END,'') <> ''
) AS s WHERE Value IS NOT NULL
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Suffix Name' AS source
FROM    street_locality
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Type Name' AS source
FROM    street_locality
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> '';

/*
 * View to extract unified index values for street_locality_alias
 */
CREATE OR REPLACE VIEW street_locality_alias_unidex AS
SELECT  'alpha' AS processing,
        substring(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality_alias
WHERE   COALESCE(substring(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'phonetic' AS processing,
        dmetaphone(street_name) AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality_alias
WHERE   COALESCE(dmetaphone(street_name),'') <> ''
UNION ALL
SELECT * FROM (
SELECT  'phonetic' AS processing,
        CASE WHEN dmetaphone(street_name) <> dmetaphone_alt(street_name) THEN dmetaphone_alt(street_name) ELSE NULL END AS value,
        load_batch_id,
        0.70 AS confidence,
        record_guid,
        'Street Name' AS source
FROM    street_locality_alias
WHERE   COALESCE(CASE WHEN dmetaphone(street_name) <> dmetaphone_alt(street_name) THEN dmetaphone_alt(street_name) ELSE NULL END,'') <> ''
) AS s WHERE Value IS NOT NULL
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Suffix Name' AS source
FROM    street_locality_alias
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> ''
UNION ALL
SELECT  'typo' AS processing,
        substring(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32) AS value,
        load_batch_id,
        0.90 AS confidence,
        record_guid,
        'Street Type Name' AS source
FROM    street_locality_alias
WHERE   COALESCE(substring(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) for 32),'') <> '';

CREATE OR REPLACE VIEW gnaf_unidex AS
SELECT * FROM address_detail_unidex
UNION ALL SELECT * FROM locality_unidex
UNION ALL SELECT * FROM locality_alias_unidex
UNION ALL SELECT * FROM street_locality_unidex
UNION ALL SELECT * FROM street_locality_alias_unidex;
