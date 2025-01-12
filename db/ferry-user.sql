-- This only has to be done once to initialize the new user.
-- Run this in the ferry DB.

GRANT ALL ON SCHEMA public TO ferry;
ALTER SCHEMA public OWNER TO ferry;
GRANT ALL ON ALL TABLES IN SCHEMA public TO ferry;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ferry;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ferry;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ferry;