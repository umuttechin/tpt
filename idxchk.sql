#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./idxchk.sql" 1>&2;
          echo "./idxchk.sql \"schema_name = '\$schema_name'\"" 1>&2;
	  echo "./idxchk.sql \"table_name = '\$table_name'\"" 1>&2;
	  echo "./idxchk.sql \"index_name = '\$index_name'\"" 1>&2;
	  echo "./idxchk.sql \"schema_name = '\$schema_name' and table_name = '\$table_name'\"" 1>&2;
	  echo "./idxchk.sql \"table_name = '\$table_name' and index_name = '\$index_name'\"" 1>&2;
	  echo "./idxchk.sql \"schema_name = '\$schema_name' and table_name = '\$table_name' and index_name = '\$index_name'\"" 1>&2;
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
	psql -c "with maintab
     as (select t.relnamespace :: regnamespace :: varchar schema_name,
         t.relname                                 as table_name,
         i.relname                                 as index_name,
         a.attname                                 as column_name,
         --am.amname as access_method,
         array_position(ix.indkey, a.attnum)       as col_idx_order
         from   pg_class t,
         pg_class i,
         pg_index ix,
         pg_attribute a,
         pg_am am
         where  t.oid = ix.indrelid
         and i.oid = ix.indexrelid
         and a.attrelid = t.oid
         and a.attnum = any ( ix.indkey )
         --and t.relkind = 'r'
         and i.relam = am.oid)
select *
from   maintab 
order  by schema_name, table_name, index_name, col_idx_order;"
else
    psql -c "with maintab
     as (select t.relnamespace :: regnamespace :: varchar schema_name,
         t.relname                                 as table_name,
         i.relname                                 as index_name,
         a.attname                                 as column_name,
         --am.amname as access_method,
         array_position(ix.indkey, a.attnum)       as col_idx_order
         from   pg_class t,
         pg_class i,
         pg_index ix,
         pg_attribute a,
         pg_am am
         where  t.oid = ix.indrelid
         and i.oid = ix.indexrelid
         and a.attrelid = t.oid
         and a.attnum = any ( ix.indkey )
         --and t.relkind = 'r'
         and i.relam = am.oid)
select *
from   maintab
where  $condition
order  by schema_name, table_name, index_name, col_idx_order;" 2>/dev/null || usage
fi
