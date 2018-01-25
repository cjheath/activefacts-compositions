CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;



/*
 * View to extract unified index values for address_detail
 */
CREATE OR REPLACE VIEW address_detail_unidex AS
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(building_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(building_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = building_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'building_name' AS source_field
FROM    address_detail
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(building_name), dmetaphone_alt(building_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'building_name' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(flat_number, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(flat_number, '[^[:alnum:]]+', ' ', 'g'))), 32) = flat_number THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'flat_number' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(flat_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(flat_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) = flat_number_prefix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'flat_number_prefix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(flat_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(flat_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) = flat_number_suffix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'flat_number_suffix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'flat_type' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(legal_parcel_id, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(legal_parcel_id, '[^[:alnum:]]+', ' ', 'g'))), 32) = legal_parcel_id THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'legal_parcel_id' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(level_number, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(level_number, '[^[:alnum:]]+', ' ', 'g'))), 32) = level_number THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'level_number' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(level_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(level_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) = level_number_prefix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'level_number_prefix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(level_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(level_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) = level_number_suffix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'level_number_suffix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'level_type' AS source_field
FROM    address_detail
UNION ALL
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(location_description), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'location_description' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(lot_number, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(lot_number, '[^[:alnum:]]+', ' ', 'g'))), 32) = lot_number THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'lot_number' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(lot_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(lot_number_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) = lot_number_prefix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'lot_number_prefix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(lot_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(lot_number_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) = lot_number_suffix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'lot_number_suffix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_first, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_first, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_first THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_first' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_first_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_first_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_first_prefix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_first_prefix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_first_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_first_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_first_suffix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_first_suffix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_last, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_last, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_last THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_last' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_last_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_last_prefix, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_last_prefix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_last_prefix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(number_last_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(number_last_suffix, '[^[:alnum:]]+', ' ', 'g'))), 32) = number_last_suffix THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'number_last_suffix' AS source_field
FROM    address_detail
UNION ALL
SELECT
        'simple' AS processing,
        left(postcode, 32) AS value,
        load_batch_id,
        1.0 AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'postcode' AS source_field
FROM    address_detail
UNION ALL
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(private_street), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'address_detail' AS source_table,
        'private_street' AS source_field
FROM    address_detail;

/*
 * View to extract unified index values for address_site
 */
CREATE OR REPLACE VIEW address_site_unidex AS
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(address_site_name), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'address_site' AS source_table,
        'address_site_name' AS source_field
FROM    address_site;


/*
 * View to extract unified index values for locality
 */
CREATE OR REPLACE VIEW locality_unidex AS
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(locality_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(locality_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = locality_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'locality' AS source_table,
        'locality_name' AS source_field
FROM    locality
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(locality_name), dmetaphone_alt(locality_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'locality' AS source_table,
        'locality_name' AS source_field
FROM    locality
UNION ALL
SELECT
        'simple' AS processing,
        left(primary_postcode, 32) AS value,
        load_batch_id,
        1.0 AS confidence,
        record_guid,
        'locality' AS source_table,
        'primary_postcode' AS source_field
FROM    locality
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'locality' AS source_table,
        'state' AS source_field
FROM    locality;

/*
 * View to extract unified index values for locality_alias
 */
CREATE OR REPLACE VIEW locality_alias_unidex AS
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(name, '[^[:alnum:]]+', ' ', 'g'))), 32) = name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'locality_alias' AS source_table,
        'name' AS source_field
FROM    locality_alias
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(name), dmetaphone_alt(name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'locality_alias' AS source_table,
        'name' AS source_field
FROM    locality_alias
UNION ALL
SELECT
        'simple' AS processing,
        left(postcode, 32) AS value,
        load_batch_id,
        1.0 AS confidence,
        record_guid,
        'locality_alias' AS source_table,
        'postcode' AS source_field
FROM    locality_alias
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'locality_alias' AS source_table,
        'state' AS source_field
FROM    locality_alias;



/*
 * View to extract unified index values for street_locality
 */
CREATE OR REPLACE VIEW street_locality_unidex AS
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = street_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality' AS source_table,
        'street_name' AS source_field
FROM    street_locality
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = street_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality' AS source_table,
        'street_name' AS source_field
FROM    street_locality
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(street_name), dmetaphone_alt(street_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'street_locality' AS source_table,
        'street_name' AS source_field
FROM    street_locality
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality' AS source_table,
        'street_suffix' AS source_field
FROM    street_locality
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality' AS source_table,
        'street_type' AS source_field
FROM    street_locality;

/*
 * View to extract unified index values for street_locality_alias
 */
CREATE OR REPLACE VIEW street_locality_alias_unidex AS
SELECT
        'alpha' AS processing,
        left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = street_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality_alias' AS source_table,
        'street_name' AS source_field
FROM    street_locality_alias
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = street_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality_alias' AS source_table,
        'street_name' AS source_field
FROM    street_locality_alias
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(street_name), dmetaphone_alt(street_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'street_locality_alias' AS source_table,
        'street_name' AS source_field
FROM    street_locality_alias
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality_alias' AS source_table,
        'street_suffix' AS source_field
FROM    street_locality_alias
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))), 32) =  (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id) THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'street_locality_alias' AS source_table,
        'street_type' AS source_field
FROM    street_locality_alias;

CREATE OR REPLACE VIEW gnaf_unidex AS
SELECT * FROM address_detail_unidex
UNION ALL SELECT * FROM address_site_unidex
UNION ALL SELECT * FROM locality_unidex
UNION ALL SELECT * FROM locality_alias_unidex
UNION ALL SELECT * FROM street_locality_unidex
UNION ALL SELECT * FROM street_locality_alias_unidex;
