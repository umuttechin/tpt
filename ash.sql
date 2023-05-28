#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./ash.sql" 1>&2;
	  echo "./ash.sql \"\$cols \$predicate \$date1 \$date2" 1>&2;
	  echo "./ash.sql wait_event 1=1 \"now()-interval '15 minutes'\"  \"now()\"" 1>&2;
	  echo "./ash.sql wait_event \"datname='pgbench'\" \"now()-interval '15 minutes'\" \"now()\"" 1>&2;
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

cols=$1
condition=$2
date1=$3
date2=$4


if [ -z "${condition}" ]; then
        psql -c "WITH ash AS
(
       SELECT *,
              Ceil(Extract(epoch FROM Max(ash_time)OVER() - Min(ash_time)OVER()))::numeric samples
       FROM   pg_active_session_history
       WHERE  ash_time >= CURRENT_TIMESTAMP - INTERVAL '10 minutes')
           SELECT * FROM ash order by 1 desc"
else
    psql -c "WITH ash AS
(
       SELECT *,
              Ceil(Extract(epoch FROM Max(ash_time)OVER() - Min(ash_time)OVER()))::numeric samples
       FROM   pg_active_session_history
       WHERE  ash_time between $date1 and  $date2)
           SELECT Round(Count(*) / samples, 2) AS aas,
           Round(Count(*)/Sum(Count(*))OVER(),2)*100 AS percentage,
           $cols
           FROM ash
           where $condition
           group by samples, $cols
           order by 1 desc, $cols
           ;" 2>/dev/null || usage
fi

