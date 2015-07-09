#!/usr/bin/env bash

dropdb -U rails data_entry_development
createdb -U rails data_entry_development
psql -U rails data_entry_development < ../db/migrate/data/sessions.sql
psql -U rails data_entry_development < ../db/migrate/data/data_entry_production.sql
psql -U rails data_entry_development < ../db/migrate/data/add_analysis_account.sql
psql -U rails data_entry_development < ./plpython/yaml-parse.sql
