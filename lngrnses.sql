#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./lngrnses.sql" 1>&2;
          echo "./lngrnses.sql \"'\$time_interval'\"" 1>&2;
          echo "./lngrnses.sql \"'5 minutes'\"" 1>&2;
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
	psql -c "select
  pid,
  now() - pg_stat_activity.query_start as duration,
  state,
  'select pg_cancel_backend('||pid||');' as kill_command,
  query
  from pg_stat_activity
  where state = 'active'
  and (now() - pg_stat_activity.query_start) > interval '10 minutes';"
else
    psql -c "select
  pid,
  now() - pg_stat_activity.query_start as duration,
  state,
  'select pg_cancel_backend('||pid||');' as kill_command,
  query
  from pg_stat_activity
  where state = 'active'
  and (now() - pg_stat_activity.query_start) > interval $1;" 2>/dev/null || usage
fi
