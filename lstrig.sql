#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./lstrig.sql" 1>&2;
          echo "./lstrig.sql \"trigger_schema = '\$schema_name'\"" 1>&2;
          echo "./lstrig.sql \"trigger_name = '\$trigger_name'\"" 1>&2;
          echo "./lstrig.sql \"event_object_table = '\$table_name_trigger_on'\"" 1>&2;
          echo "./lstrig.sql \"trigger_schema = '\$schema_name' and trigger_name = '\$trigger_name'\"" 1>&2;
          echo "./lstrig.sql \"trigger_name = '\$trigger_name' and event_object_table = '\$table_name_trigger_on'\"" 1>&2;
          echo "./lstrig.sql \"trigger_schema = '\$schema_name' and trigger_name = '\$trigger_name' and event_object_table = '\$table_name_trigger_on'\"" 1>&2;
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
    psql -c "select distinct trigger_schema, -- due to multiple event_manipulation
       trigger_name,
       event_object_table,
       pg_get_triggerdef(oid)
from   information_schema.triggers it
       join pg_trigger t
       on it.trigger_name = t.tgname
       and cast(t.tgrelid :: regclass as varchar) = it.event_object_table
order  by 1, 2; "
else
    psql -c "select distinct trigger_schema, -- due to multiple event_manipulation
       trigger_name,
       event_object_table,
       pg_get_triggerdef(oid)
from   information_schema.triggers it
       join pg_trigger t
       on it.trigger_name = t.tgname
       and cast(t.tgrelid :: regclass as varchar) = it.event_object_table
       where $1
order  by 1, 2; " 2>/dev/null || usage
fi
