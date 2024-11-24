-- See: https://hasura.io/docs/2.0/deployment/postgres-requirements/#2-a-single-role-to-manage-metadata-and-user-objects-in-the-same-database
-- This only has to be done once to initialize the new user.
-- Run this in the ferry DB.

-- If you started the GQL engine with the hasura user, then you can ignore
-- the hdb_catalog setup steps.
CREATE SCHEMA IF NOT EXISTS hdb_catalog;
ALTER SCHEMA hdb_catalog OWNER TO hasura;
DO $$
DECLARE
   obj RECORD;
BEGIN
   FOR obj IN
      SELECT format('ALTER TABLE %I.%I OWNER TO %I;', schemaname, tablename, 'hasura') AS cmd
      FROM pg_tables WHERE schemaname = 'hdb_catalog'
      UNION ALL
      SELECT format('ALTER SEQUENCE %I.%I OWNER TO %I;', schemaname, sequencename, 'hasura') AS cmd
      FROM pg_sequences WHERE schemaname = 'hdb_catalog'
      UNION ALL
      SELECT format('ALTER FUNCTION %I.%I(%s) OWNER TO %I;',
                    n.nspname, p.proname,
                    pg_get_function_identity_arguments(p.oid),
                    'hasura') AS cmd
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = 'hdb_catalog';
   LOOP
      EXECUTE obj.cmd;
   END LOOP;
END $$;

-- Only give read permissions to the data tables.
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO hasura;
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO hasura;

GRANT USAGE ON SCHEMA public TO hasura;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hasura;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO hasura;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO hasura;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO hasura;

-- To verify that the right permissions are present:
-- 1. Check that hasura owns the metadata tables:
--    SELECT * from pg_catalog.pg_tables where schemaname = 'hdb_catalog';
-- 2. Check that hasura can query the data tables:
--    SELECT * from seasons;
