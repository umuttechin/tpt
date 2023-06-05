#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./ises.sql" 1>&2;
          echo "./ises.sql \"'\$time_interval'\"" 1>&2;
          echo "./ises.sql \"'1 minutes'\"" 1>&2;
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
        psql -c "select pid,
       query,
       'select pg_cancel_backend('||pid||');' as kill_command
from pg_stat_activity
where pid <> pg_backend_pid()
  and state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
  and current_timestamp - state_change > interval '10 minutes' order by 1;"
else
    psql -c "select pid,
       query,
       'select pg_cancel_backend('||pid||');' as kill_command
from pg_stat_activity
where pid <> pg_backend_pid()
  and state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
  and current_timestamp - state_change > interval $condition order by 1;" 2>/dev/null || usage
fi

