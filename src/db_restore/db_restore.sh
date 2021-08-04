#!/usr/bin/env bash
echo "Restoring database"
pg_restore -w -U postgres -d ${POSTGRES_DB} /docker-entrypoint-initdb.d/dvdrental.tar
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO postgres"
echo "Database restored successfully"