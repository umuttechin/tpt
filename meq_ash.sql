#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./meq_ash.sql" 1>&2;
          echo "./meq_ash.sql \"time interval = '\$time_interval'\"" 1>&2;
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
        psql -c "with ash as
(
       select *,
              ceil(extract(epoch from max(ash_time)over() - min(ash_time)over()))::numeric samples
       from   pg_active_session_history
       where  ash_time >= current_timestamp - interval '10 minutes')
select          round(count(*) / sum(count(*))over(),2)*100 as percentage,
                round(count(*) / samples, 2) as aas,
                backend_type,
                queryid,
                pg.query
from            ash
left outer join pg_stat_statements pg
using          (queryid)
group by        backend_type,
                queryid,
                pg.query,
                samples
order by        1 desc;"
else
    psql -c "with ash as
(
       select *,
              ceil(extract(epoch from max(ash_time)over() - min(ash_time)over()))::numeric samples
       from   pg_active_session_history
       where  ash_time >= current_timestamp - interval $condition)
select          round(count(*) / sum(count(*))over(),2)*100 as percentage,
                round(count(*) / samples, 2)                as aas,
                backend_type,
                queryid,
                pg.query
from            ash
left outer join pg_stat_statements pg
using          (queryid)
group by        backend_type,
                queryid,
                pg.query,
                samples
order by        1 desc;" 2>/dev/null || usage
fi

