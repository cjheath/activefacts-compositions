CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;

/*
 * View to extract unified index values for location
 */
CREATE OR REPLACE VIEW location_unidex AS
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(address_text), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'location' AS source_table,
        'address_text' AS source_field
FROM    location;

/*
 * View to extract unified index values for person
 */
CREATE OR REPLACE VIEW person_unidex AS
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(alias_name), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'person' AS source_table,
        'alias_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'names' AS processing,
        dmetaphone(left(unnest(regexp_split_to_array(lower(alias_name), E'[^[:alnum:]''-]+')), 32)) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'alias_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'names' AS processing,
        dmetaphone_alt(left(unnest(regexp_split_to_array(lower(alias_name), E'[^[:alnum:]''-]+')), 32)) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'alias_name' AS source_field
FROM    person
UNION ALL
SELECT
        'email' AS processing,
        left(unnest(regexp_matches(email_address, E'[-_.[:alnum:]]+@[-_.[:alnum:]]+')), 32) AS value,
        load_batch_id,
        1 AS confidence,
        record_guid,
        'person' AS source_table,
        'email_address' AS source_field
FROM    person
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(family_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(family_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = family_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'person' AS source_table,
        'family_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(family_name), dmetaphone_alt(family_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'family_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'words' AS processing,
        left(unnest(regexp_split_to_array(lower(given_name), E'[^[:alnum:]]+')), 32) AS value,
        load_batch_id,
        0.9 AS confidence,
        record_guid,
        'person' AS source_table,
        'given_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'names' AS processing,
        dmetaphone(left(unnest(regexp_split_to_array(lower(given_name), E'[^[:alnum:]''-]+')), 32)) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'given_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'names' AS processing,
        dmetaphone_alt(left(unnest(regexp_split_to_array(lower(given_name), E'[^[:alnum:]''-]+')), 32)) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'given_name' AS source_field
FROM    person
UNION ALL
SELECT
        'phone' AS processing,
        right(regexp_split_to_table(regexp_replace(phone_number, '[^0-9]+', '', 'g'), E',\\|'), 8) AS value,
        load_batch_id,
        1 AS confidence,
        record_guid,
        'person' AS source_table,
        'phone_number' AS source_field
FROM    person
UNION ALL
SELECT
        'typo' AS processing,
        left(btrim(lower(regexp_replace(preferred_name, '[^[:alnum:]]+', ' ', 'g'))), 32) AS value,
        load_batch_id,
        CASE WHEN left(btrim(lower(regexp_replace(preferred_name, '[^[:alnum:]]+', ' ', 'g'))), 32) = preferred_name THEN 1.0 ELSE 0.95 END AS confidence,
        record_guid,
        'person' AS source_table,
        'preferred_name' AS source_field
FROM    person
UNION ALL
SELECT DISTINCT
        'phonetic' AS processing,
        unnest(ARRAY[dmetaphone(preferred_name), dmetaphone_alt(preferred_name)]) AS value,
        load_batch_id,
        0.7 AS confidence,
        record_guid,
        'person' AS source_table,
        'preferred_name' AS source_field
FROM    person;



CREATE OR REPLACE VIEW synthetic_unidex AS
SELECT * FROM location_unidex
UNION ALL SELECT * FROM person_unidex;
