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
    psql -c "select table_schema as view_schema,
       table_name   as view_name,
       view_definition
from   information_schema.views v
order  by 1,
          2;"
else
    psql -c "select table_schema as view_schema,
       table_name   as view_name,
       view_definition
from   information_schema.views v
where $condition
order  by 1, 2;" 2>/dev/null || usage
fi
