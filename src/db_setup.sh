#!/usr/bin/env bash
# Paths
data_url=https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip
dwnld_dir=/var/lib/postgresql

DBNAME='dvdrental'


# Download and unzip
mkdir -p ${dwnld_dir}
cd ${dwnld_dir}
wget -N ${data_url}
unzip ${dwnld_dir}/dvdrental.zip

# Restore
echo "Restoring database"
psql -U postgres -c "CREATE DATABASE ${DBNAME}"
pg_restore -w -U postgres -d ${DBNAME} ${dwnld_dir}/dvdrental.tar
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DBNAME} TO postgres"
echo "Database restored successfully"

rm ${dwnld_dir}/dvdrental.*