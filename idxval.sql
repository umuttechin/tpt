#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./idxval.sql" 1>&2;
          echo "./idxval.sql \"schemaname = '\$schema_name'\"" 1>&2;
          echo "./idxval.sql \"tablename = '\$table_name'\"" 1>&2;
          echo "./idxval.sql \"schemaname = '\$schema_name' and tablename = '\$table_name'\"" 1>&2;
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
        psql -c "with recursive partitions as
(
       select inhrelid,
       inhparent
       from   pg_inherits
       where  inhparent in
       (
       select oid
       from   parent)
       union
       select i.inhrelid,
       i.inhparent
       from   pg_inherits i
       join   partitions p
       on     i.inhparent = p.inhrelid), parent as
(
       select t.tablename::regclass::oid as oid
       from   pg_tables t where schemaname != 'information_schema'), tableoids as
(
       select oid
       from   parent
       union
       select inhrelid as id
       from   partitions)
select indexrelid::regclass as index_name,
       indrelid::regclass   as table_or_partition_name,
       indisunique          as isunique,
       indisprimary         as isprimary,
       indisvalid           as isvalid
from   pg_index
where  indrelid in (select * from   tableoids)
order by 1, 2;"
else
    psql -c "with recursive partitions as
(
       select inhrelid,
       inhparent
       from   pg_inherits
       where  inhparent in
       (
       select oid
       from   parent)
       union
       select i.inhrelid,
       i.inhparent
       from   pg_inherits i
       join   partitions p
       on     i.inhparent = p.inhrelid), parent as
(
       select t.tablename::regclass::oid as oid
       from   pg_tables t
       where  schemaname != 'information_schema' and $condition), tableoids as
(
       select oid
       from   parent
       union
       select inhrelid as id
       from   partitions)
select indexrelid::regclass as index_name,
       indrelid::regclass   as table_or_partition_name,
       indisunique          as isunique,
       indisprimary         as isprimary,
       indisvalid           as isvalid
from   pg_index
where  indrelid in (select * from   tableoids)
order by 1, 2;" 2>/dev/null || usage
fi
