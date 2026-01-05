#!/bin/sh
set -eu

echo "Initializing application databases and users..."

# Fail fast if required secrets are missing
: "${AUTHENTIK_POSTGRESQL__PASSWORD:?AUTHENTIK_POSTGRESQL__PASSWORD is required}"
: "${LINKWARDEN_POSTGRESQL__PASSWORD:?LINKWARDEN_POSTGRESQL__PASSWORD is required}"

psql -v ON_ERROR_STOP=1 \
  -v authentik_pw="$AUTHENTIK_POSTGRESQL__PASSWORD" \
  -v linkwarden_pw="$LINKWARDEN_POSTGRESQL__PASSWORD" \
  <<'SQL'

-- ================== Authentik ==================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'authentik'
  ) THEN
    CREATE ROLE authentik LOGIN;
  END IF;
END
$$;

ALTER ROLE authentik PASSWORD :'authentik_pw';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = 'authentik'
  ) THEN
    CREATE DATABASE authentik OWNER authentik;
  END IF;
END
$$;

-- ================== Linkwarden ==================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'linkwarden'
  ) THEN
    CREATE ROLE linkwarden LOGIN;
  END IF;
END
$$;

ALTER ROLE linkwarden PASSWORD :'linkwarden_pw';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = 'linkwarden'
  ) THEN
    CREATE DATABASE linkwarden OWNER linkwarden;
  END IF;
END
$$;

SQL

echo "Database initialization complete."
