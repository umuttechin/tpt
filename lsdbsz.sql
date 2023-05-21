#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./lsdbsz.sql" 1>&2;
          echo "./lsdbsz.sql \"datname = '\$db_name'\"" 1>&2;
          echo "";
 exit 1; }

while getopts ":h" o; do
    case "${o}" in
        h)
            usage
                        ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

condition=$1

if [ -z "${condition}" ]; then
    psql -c "select datname                      as db_name,
       pg_size_pretty(pg_database_size(datname)) as db_size
from   pg_database
order  by pg_database_size(datname) desc;"
else
    psql -c "select datname                      as db_name,
       pg_size_pretty(pg_database_size(datname)) as db_size
from   pg_database
where $condition
order  by pg_database_size(datname) desc;" 2>/dev/null || usage
fi
