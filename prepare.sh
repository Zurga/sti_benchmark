#! /usr/bin/env bash
LIKE_AMOUNT=${1:-500}
USER_AMOUNT=${2:-1000}
dropdb sti
createdb sti
dropdb inheritance
createdb inheritance 
sed -e "s/USER_AMOUNT/"$USER_AMOUNT"/g" -e "s/LIKE_AMOUNT/"$LIKE_AMOUNT"/g" sti.sql | psql -d sti
sed -e "s/USER_AMOUNT/"$USER_AMOUNT"/g" -e "s/LIKE_AMOUNT/"$LIKE_AMOUNT"/g" inheritance_table.sql | psql -d inheritance
elixir benchee.exs
