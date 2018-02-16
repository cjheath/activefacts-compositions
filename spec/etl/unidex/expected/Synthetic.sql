CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;

/*
 * View to extract unified index values for location
 */
CREATE OR REPLACE VIEW location_unidex AS
SELECT DISTINCT
        unnest(regexp_split_to_array(lower(address_text), E'[^[:alnum:]]+')) AS value,
        NULL AS phonetic,
        'words'::text AS processing,
        'location'::text AS source_table,
        'address_text'::text AS source_field,
        load_batch_id,
        record_guid
FROM    location;

/*
 * View to extract unified index values for person
 */
CREATE OR REPLACE VIEW person_unidex AS
SELECT DISTINCT
        value,
	unnest(ARRAY[dmetaphone(value), dmetaphone_alt(value)]) AS phonetic,
	processing,
	source_table,
	source_field,
	load_batch_id,
	record_guid
FROM (
	SELECT DISTINCT
	        unnest(regexp_split_to_array(lower(alias_name), E'[^[:alnum:]''-]+')) AS value,
	        NULL AS phonetic,
	        'names'::text AS processing,
	        'person'::text AS source_table,
	        'alias_name'::text AS source_field,
	        load_batch_id,
	        record_guid
	FROM    person
) AS s
UNION ALL
SELECT DISTINCT
        unnest(regexp_matches(email_address, E'[-_.[:alnum:]]+@[-_.[:alnum:]]+')) AS value,
        NULL AS phonetic,
        'email'::text AS processing,
        'person'::text AS source_table,
        'email_address'::text AS source_field,
        load_batch_id,
        record_guid
FROM    person
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(family_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(family_name), dmetaphone_alt(family_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'person'::text AS source_table,
        'family_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    person
UNION ALL
SELECT DISTINCT
        value,
	unnest(ARRAY[dmetaphone(value), dmetaphone_alt(value)]) AS phonetic,
	processing,
	source_table,
	source_field,
	load_batch_id,
	record_guid
FROM (
	SELECT DISTINCT
	        unnest(regexp_split_to_array(lower(given_name), E'[^[:alnum:]''-]+')) AS value,
	        NULL AS phonetic,
	        'names'::text AS processing,
	        'person'::text AS source_table,
	        'given_name'::text AS source_field,
	        load_batch_id,
	        record_guid
	FROM    person
) AS s
UNION ALL
SELECT DISTINCT
        right(regexp_split_to_table(regexp_replace(phone_number, '[^0-9]+', '', 'g'), E',\\|'), 8) AS value,
        NULL AS phonetic,
        'phone'::text AS processing,
        'person'::text AS source_table,
        'phone_number'::text AS source_field,
        load_batch_id,
        record_guid
FROM    person
UNION ALL
SELECT DISTINCT
        btrim(lower(regexp_replace(preferred_name, '[^[:alnum:]]+', ' ', 'g'))) AS value,
        unnest(ARRAY[dmetaphone(preferred_name), dmetaphone_alt(preferred_name)]) AS phonetic,
        'phonetic'::text AS processing,
        'person'::text AS source_table,
        'preferred_name'::text AS source_field,
        load_batch_id,
        record_guid
FROM    person;



CREATE OR REPLACE VIEW synthetic_unidex AS
SELECT * FROM location_unidex
UNION ALL SELECT * FROM person_unidex;
