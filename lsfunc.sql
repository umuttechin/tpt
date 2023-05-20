#!/bin/bash

#if [ "$#" -ne 0 || "$#" -ne 2 ||"$#" -ne 4 ]; then
#    usage
#fi

unset o OPTARG OPTIND 

usage() { echo "Usage Examples:" 1>&2;
          echo "./lsfunc.sql" 1>&2;
          echo "./lsfunc.sql \"nspname = '\$schema_name'\"" 1>&2;
          echo "./lsfunc.sql \"proname = '\$function_name'\"" 1>&2;
          echo "./lsfunc.sql \"nspname = '\$schema_name' and proname = '\$function_name'\"" 1>&2;
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
    psql -c "select pronamespace::regnamespace as schema, proname as function_name, pg_get_functiondef(pr.oid) as function_def from pg_proc pr
    join pg_namespace pn on pr.pronamespace = pn.oid where pn.nspname not in ('pg_toast', 'pg_catalog', 'information_schema') and prokind != 'a';"
else
    psql -c "select pronamespace::regnamespace as schema, proname as function_name, pg_get_functiondef(pr.oid) as function_def from pg_proc pr
    join pg_namespace pn on pr.pronamespace = pn.oid where pn.nspname not in ('pg_toast', 'pg_catalog', 'information_schema') and prokind != 'a'
    and $condition;" 2>/dev/null || usage
fi
