#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL

	DO \$\$ 
	BEGIN
		IF NOT EXISTS (SELECT FROM   pg_catalog.pg_user WHERE  usename = 'catan_leaderboards') THEN
      			CREATE USER catan_leaderboards CREATEDB PASSWORD '$RAILS_PASSWORD';
    		END IF;
		IF NOT EXISTS (SELECT FROM   pg_catalog.pg_user WHERE  usename = 'Bencinera') THEN
			CREATE USER "Bencinera" CREATEDB PASSWORD '$BENCINERA_DATABASE_PASSWORD';
		END IF;
			IF NOT EXISTS (SELECT FROM   pg_catalog.pg_user WHERE  usename = 'catan_leaderboards') THEN
		CREATE USER owncloud CREATEDB PASSWORD '$OWNCLOUD_PASSWORD';  
			END IF;
		IF NOT EXISTS (SELECT FROM   pg_database WHERE datname = 'owncloud') THEN
			CREATE DATABASE owncloud; 
		END IF;
		GRANT ALL PRIVILEGES ON DATABASE owncloud TO owncloud; 
	END 
	\$\$
EOSQL
