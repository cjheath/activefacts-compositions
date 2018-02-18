CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;



/*
 * View to extract unified index values for address_detail
 */
CREATE OR REPLACE VIEW address_detail_unidex AS
SELECT DISTINCT
        btrim(lower(regexp_replace(building_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(building_name), dmetaphone_alt(building_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'address_detail'::text AS source_table,
        'building_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(flat_number, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'flat_number'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(flat_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'flat_number_prefix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(flat_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'flat_number_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM flat_type AS f WHERE address_detail.flat_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'flat_type'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(legal_parcel_id, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'legal_parcel_id'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(level_number, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'level_number'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(level_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'level_number_prefix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(level_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'level_number_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM level_type AS f WHERE address_detail.level_type_code = f.code AND address_detail.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'level_type'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        unnest(regexp_split_to_array(lower(location_description), E'[^[:alnum:]]+')) AS value,
        NULL AS phonetic,
        'words'::text AS processing,
        'address_detail'::text AS source_table,
        'location_description'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(lot_number, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'lot_number'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(lot_number_prefix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'lot_number_prefix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(lot_number_suffix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'lot_number_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_first, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_first'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_first_prefix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_first_prefix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_first_suffix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_first_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_last, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_last'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_last_prefix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_last_prefix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(number_last_suffix, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'address_detail'::text AS source_table,
        'number_last_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        postcode AS value,
        NULL AS phonetic,
        'simple'::text AS processing,
        'address_detail'::text AS source_table,
        'postcode'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail
UNION ALL
SELECT DISTINCT
        unnest(regexp_split_to_array(lower(private_street), E'[^[:alnum:]]+')) AS value,
        NULL AS phonetic,
        'words'::text AS processing,
        'address_detail'::text AS source_table,
        'private_street'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_detail;

/*
 * View to extract unified index values for address_site
 */
CREATE OR REPLACE VIEW address_site_unidex AS
SELECT DISTINCT
        unnest(regexp_split_to_array(lower(address_site_name), E'[^[:alnum:]]+')) AS value,
        NULL AS phonetic,
        'words'::text AS processing,
        'address_site'::text AS source_table,
        'address_site_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    address_site;


/*
 * View to extract unified index values for locality
 */
CREATE OR REPLACE VIEW locality_unidex AS
SELECT DISTINCT
        btrim(lower(regexp_replace(locality_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(locality_name), dmetaphone_alt(locality_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'locality'::text AS source_table,
        'locality_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality
UNION ALL
SELECT DISTINCT
        primary_postcode AS value,
        NULL AS phonetic,
        'simple'::text AS processing,
        'locality'::text AS source_table,
        'primary_postcode'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality.state_pid = f.state_pid AND locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'locality'::text AS source_table,
        'state'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality;

/*
 * View to extract unified index values for locality_alias
 */
CREATE OR REPLACE VIEW locality_alias_unidex AS
SELECT DISTINCT
        btrim(lower(regexp_replace(name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(name), dmetaphone_alt(name)]) AS phonetic,
        'phonetic'::text AS processing,
        'locality_alias'::text AS source_table,
        'name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality_alias
UNION ALL
SELECT DISTINCT
        postcode AS value,
        NULL AS phonetic,
        'simple'::text AS processing,
        'locality_alias'::text AS source_table,
        'postcode'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality_alias
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT state_name FROM state AS f WHERE locality_alias.state_pid = f.state_pid AND locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'locality_alias'::text AS source_table,
        'state'::text AS source_field,
        load_batch_id,
        record_guid
FROM    locality_alias;



/*
 * View to extract unified index values for street_locality
 */
CREATE OR REPLACE VIEW street_locality_unidex AS
SELECT DISTINCT
        btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality'::text AS source_table,
        'street_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(street_name), dmetaphone_alt(street_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'street_locality'::text AS source_table,
        'street_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality.street_suffix_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality'::text AS source_table,
        'street_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality.street_type_code = f.code AND street_locality.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality'::text AS source_table,
        'street_type'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality;

/*
 * View to extract unified index values for street_locality_alias
 */
CREATE OR REPLACE VIEW street_locality_alias_unidex AS
SELECT DISTINCT
        btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality_alias'::text AS source_table,
        'street_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality_alias
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(street_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(street_name), dmetaphone_alt(street_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'street_locality_alias'::text AS source_table,
        'street_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality_alias
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM street_suffix AS f WHERE street_locality_alias.street_suffix_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality_alias'::text AS source_table,
        'street_suffix'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality_alias
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace( (SELECT name FROM street_type AS f WHERE street_locality_alias.street_type_code = f.code AND street_locality_alias.load_batch_id = f.load_batch_id), '[^[:alnum:]]+', ' ', 'g'))) AS value,
        NULL AS phonetic,
        'alpha'::text AS processing,
        'street_locality_alias'::text AS source_table,
        'street_type'::text AS source_field,
        load_batch_id,
        record_guid
FROM    street_locality_alias;

CREATE OR REPLACE VIEW gnaf_unidex AS
SELECT * FROM address_detail_unidex
UNION ALL SELECT * FROM address_site_unidex
UNION ALL SELECT * FROM locality_unidex
UNION ALL SELECT * FROM locality_alias_unidex
UNION ALL SELECT * FROM street_locality_unidex
UNION ALL SELECT * FROM street_locality_alias_unidex;
