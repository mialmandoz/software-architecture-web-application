#!/bin/bash
set -e

echo "Waiting for database..."
while ! pg_isready -h db -p 5432 -U postgres; do
  echo "Database not ready, waiting..."
  sleep 2
done

echo "Database is ready!"

echo "Creating database if needed..."
mix ecto.create

echo "Running migrations..."
mix ecto.migrate

echo "Building assets..."
mix assets.setup
mix assets.build

echo "Checking if database needs seeding..."
# Simple check using psql to count authors
AUTHOR_COUNT=$(PGPASSWORD=postgres psql -h db -U postgres -d web_application_dev -t -c "SELECT COUNT(*) FROM authors;" 2>/dev/null | xargs || echo "0")

if [ "$AUTHOR_COUNT" = "0" ]; then
  echo "Database is empty, running seeds..."
  mix run priv/repo/seeds.exs
fi

echo "Starting Phoenix server..."
exec mix phx.server
