#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./ises.sql" 1>&2;
          echo "./ises.sql \"time interval = '\$time_interval'\"" 1>&2;
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
	psql -c "WITH inactive_connections AS (
    SELECT pid, rank() over (partition by client_addr order by backend_start ASC) as rank
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid( )
    AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
    AND current_timestamp - state_change > interval '5 minutes'
)
SELECT pid, 'select pg_cancel_backend('||pid||');' as kill_command
FROM inactive_connections
WHERE rank > 1;"
else
    psql -c "WITH inactive_connections AS (
    SELECT pid, rank() over (partition by client_addr order by backend_start ASC) as rank
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid( )
    AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
    AND current_timestamp - state_change > interval $1
)
SELECT pid, 'select pg_cancel_backend('||pid||');' as kill_command
FROM inactive_connections
WHERE rank > 1;" 2>/dev/null || usage
fi
