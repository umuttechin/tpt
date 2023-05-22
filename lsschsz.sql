#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./lsschsz.sql" 1>&2;
          echo "./lsschsz.sql \"schema name = '\$schema_name'\"" 1>&2;
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
	psql -c "select schema_name,
       round(sum(table_size) / 1024, 2)                      as size_in_mb,
       round(sum(table_size) * 100 / database_size, 2)      as percentage
from   (select pg_catalog.pg_namespace.nspname     as schema_name,
        pg_relation_size(pg_catalog.pg_class.oid) as table_size,
        sum(pg_relation_size(pg_catalog.pg_class.oid))
        over ()                                    as database_size
        from   pg_catalog.pg_class
        join pg_catalog.pg_namespace
        on relnamespace = pg_catalog.pg_namespace.oid) t   
group  by schema_name, database_size
order  by 2 desc; "
else
    psql -c "select schema_name,
       round(sum(table_size) / 1024, 2)                      as size_in_mb,
       round(sum(table_size) * 100 / database_size, 2)      as percentage
from   (select pg_catalog.pg_namespace.nspname     as schema_name,
        pg_relation_size(pg_catalog.pg_class.oid) as table_size,
        sum(pg_relation_size(pg_catalog.pg_class.oid))
        over ()                                    as database_size
        from   pg_catalog.pg_class
        join pg_catalog.pg_namespace
        on relnamespace = pg_catalog.pg_namespace.oid) t
	    where $condition     
group  by schema_name, database_size
order  by 2 desc; " 2>/dev/null || usage
fi
