#!/bin/bash

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
    psql -c "SELECT pronamespace :: regnamespace AS SCHEMA,
       proname                      AS function_name,
       Pg_get_functiondef(pr.oid)   AS function_def
FROM   pg_proc pr
       join pg_namespace pn
         ON pr.pronamespace = pn.oid
WHERE  pn.nspname NOT IN ( 'pg_toast', 'pg_catalog', 'information_schema' )
       AND prokind != 'a'
       order by 1, 2;"
else
    psql -c "SELECT pronamespace::regnamespace AS SCHEMA,
       proname                    AS function_name,
       pg_get_functiondef(pr.oid) AS function_def
FROM   pg_proc pr
JOIN   pg_namespace pn
ON     pr.pronamespace = pn.oid
WHERE  pn.nspname NOT IN ('pg_toast',
                          'pg_catalog',
                          'information_schema')
AND    prokind != 'a'
AND    $condition
       order by 1, 2;" 2>/dev/null || usage
fi
