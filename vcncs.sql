#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./vcncs.sql" 1>&2;
          echo "./vcncs.sql \"schemaname = '\$schema_name'\"" 1>&2;
          echo "./vcncs.sql \"s.relname = '\$object_name'\"" 1>&2;
          echo "./vcncs.sql \"schemaname = '\$schema_name' and s.relname= '\$object_name'\"" 1>&2;
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
    psql -c "with configtab as
(
       select s.schemaname,
              c.relname,
              c.oid,
              case
				  when c.relkind = 'r' then 'table'
				  when c.relkind = 'i' then 'index'
				  when c.relkind = 's' then 'sequence'
				  when c.relkind = 't' then 'toast_table'
				  when c.relkind = 'v' then 'view'
				  when c.relkind = 'm' then 'materialized_view'
				  when c.relkind = 'c' then 'composize'
				  when c.relkind = 'f' then 'foreign_table'
				  when c.relkind = 'p' then 'partitioned_table'
				  when c.relkind = 'i' then 'partitioned_index'
				  end relkind,
              s.n_dead_tup,
              s.n_mod_since_analyze,
              (c.reltuples * coalesce((
              select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_analyze_scale_factor%'), current_setting('autovacuum_analyze_scale_factor'))::float8) +
              coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_analyze_threshold%'), current_setting('autovacuum_analyze_threshold'))::float8 a_threshold,
              (c.reltuples * coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_vacuum_scale_factor%'), current_setting('autovacuum_vacuum_scale_factor'))::float8) +
              coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_vacuum_threshold%'), current_setting('autovacuum_vacuum_threshold'))::float8 v_threshold
       from   pg_class c
       join   pg_stat_all_tables s
       on     c.oid = s.relid)
select schemaname as schema_name,
       relname as object_name,
       --oid,
       relkind as object_type,
       case when n_mod_since_analyze > a_threshold then 'analyze' end as candidate_analyze,
       case when n_dead_tup > v_threshold then 'vacuum' end as candite_vacuum
from   configtab order by 1, 2, 3;"
else
    psql -c "with configtab as
(
       select s.schemaname,
              c.relname,
              c.oid,
              case
				  when c.relkind = 'r' then 'table'
				  when c.relkind = 'i' then 'index'
				  when c.relkind = 's' then 'sequence'
				  when c.relkind = 't' then 'toast_table'
				  when c.relkind = 'v' then 'view'
				  when c.relkind = 'm' then 'materialized_view'
				  when c.relkind = 'c' then 'composize'
				  when c.relkind = 'f' then 'foreign_table'
				  when c.relkind = 'p' then 'partitioned_table'
				  when c.relkind = 'i' then 'partitioned_index'
				  end relkind,
              s.n_dead_tup,
              s.n_mod_since_analyze,
              (c.reltuples * coalesce((
              select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_analyze_scale_factor%'), current_setting('autovacuum_analyze_scale_factor'))::float8) +
              coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_analyze_threshold%'), current_setting('autovacuum_analyze_threshold'))::float8 a_threshold,
              (c.reltuples * coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_vacuum_scale_factor%'), current_setting('autovacuum_vacuum_scale_factor'))::float8) +
              coalesce((select split_part(x, '=', 2) from   unnest(c.reloptions) q(x)
              where  x like 'autovacuum_vacuum_threshold%'), current_setting('autovacuum_vacuum_threshold'))::float8 v_threshold
       from   pg_class c
       join   pg_stat_all_tables s
       on     c.oid = s.relid
	   where $1)
select schemaname as schema_name,
       relname as object_name,
       --oid,
       relkind as object_type,
       case when n_mod_since_analyze > a_threshold then 'analyze' end as candidate_analyze,
       case when n_dead_tup > v_threshold then 'vacuum' end as candite_vacuum
from   configtab order by 1, 2, 3;" 2>/dev/null || usage
fi
