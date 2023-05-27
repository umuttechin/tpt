#!/bin/bash

unset o OPTARG OPTIND

usage() { echo "Usage Examples:" 1>&2;
          echo "./aas_ash.sql" 1>&2;
          echo "./ass_ash.sql \"time interval = '\$time_interval'\"" 1>&2;
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
pid=$2


if [ -z "${condition}" ]; then
        psql -c "with recursive search_wait_chain(ash_time, pid, blockerpid, wait_event_type, wait_event, level, path) as
(
       select ash_time,
              pid,
              blockerpid,
              wait_event_type,
              wait_event,
              1 as level,
              'pid: '
                     ||pid
                     ||'('
                     ||wait_event_type
                     ||')-> pid:'
                     ||blockerpid as path
       from   pg_active_session_history
       where  blockers > 0
           and ash_time > current_timestamp - interval '10 minutes'
       union all
       select p.ash_time,
              p.pid,
              p.blockerpid,
              p.wait_event_type,
              p.wait_event,
              swc.level + 1 as level,
              'pid: '
                     ||p.pid
                     ||'('
                     ||p.wait_event_type
                     ||':'
                     ||p.wait_event
                     ||')->'
                     ||swc.path as path
       from   pg_active_session_history p,
              search_wait_chain swc
       where  p.blockerpid = swc.pid
           and p.ash_time > current_timestamp - interval '10 minutes'
       and    p.ash_time = swc.ash_time
       and    p.blockers > 0 )
select   round(count(*)/cnt)*100
                  ||'%' as of_total_wait,
         count(*)       as seconds,
         path           as wait_chain
from     (
                select pid,
                       wait_event,
                       path,
                       sum(count)over() as cnt
                from   (
                                select   ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path,
                                         count(*)                                   as count,
                                         max(level)over(partition by ash_time, pid) as max_level
                                from     search_wait_chain
                                where    level > 0
                                group by ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path) as all_wait_chain
                where  level = max_level) as wait_chain
group by path,
         cnt
order by count(*) desc;"
elif [ ! -z "${condition}" ] && [ -z "${pid}" ] ; then
    psql -c "with recursive search_wait_chain(ash_time, pid, blockerpid, wait_event_type, wait_event, level, path) as
(
       select ash_time,
              pid,
              blockerpid,
              wait_event_type,
              wait_event,
              1 as level,
              'pid: '
                     ||pid
                     ||'('
                     ||wait_event_type
                     ||')-> pid:'
                     ||blockerpid as path
       from   pg_active_session_history
       where  blockers > 0
           and ash_time > current_timestamp - interval $condition
       union all
       select p.ash_time,
              p.pid,
              p.blockerpid,
              p.wait_event_type,
              p.wait_event,
              swc.level + 1 as level,
              'pid: '
                     ||p.pid
                     ||'('
                     ||p.wait_event_type
                     ||':'
                     ||p.wait_event
                     ||')->'
                     ||swc.path as path
       from   pg_active_session_history p,
              search_wait_chain swc
       where  p.blockerpid = swc.pid
           and p.ash_time > current_timestamp - interval $condition
       and    p.ash_time = swc.ash_time
       and    p.blockers > 0 )
select   round(count(*)/cnt)*100
                  ||'%' as of_total_wait,
         count(*)       as seconds,
         path           as wait_chain
from     (
                select pid,
                       wait_event,
                       path,
                       sum(count)over() as cnt
                from   (
                                select   ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path,
                                         count(*)                                   as count,
                                         max(level)over(partition by ash_time, pid) as max_level
                                from     search_wait_chain
                                where    level > 0
                                group by ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path) as all_wait_chain
                where  level = max_level) as wait_chain
group by path,
         cnt
order by count(*) desc;" 2>/dev/null || usage
else
    psql -c "with recursive search_wait_chain(ash_time, pid, blockerpid, wait_event_type, wait_event, level, path) as
(
       select ash_time,
              pid,
              blockerpid,
              wait_event_type,
              wait_event,
              1 as level,
              'pid: '
                     ||pid
                     ||'('
                     ||wait_event_type
                     ||')-> pid:'
                     ||blockerpid as path
       from   pg_active_session_history
       where  blockers > 0
           and pid = $pid
           and ash_time > current_timestamp - interval $condition
       union all
       select p.ash_time,
              p.pid,
              p.blockerpid,
              p.wait_event_type,
              p.wait_event,
              swc.level + 1 as level,
              'pid: '
                     ||p.pid
                     ||'('
                     ||p.wait_event_type
                     ||':'
                     ||p.wait_event
                     ||')->'
                     ||swc.path as path
       from   pg_active_session_history p,
              search_wait_chain swc
       where  p.blockerpid = swc.pid
           and p.ash_time > current_timestamp - interval $condition
       and    p.ash_time = swc.ash_time
       and    p.blockers > 0 )
select   round(count(*)/cnt)*100
                  ||'%' as of_total_wait,
         count(*)       as seconds,
         path           as wait_chain
from     (
                select pid,
                       wait_event,
                       path,
                       sum(count)over() as cnt
                from   (
                                select   ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path,
                                         count(*)                                   as count,
                                         max(level)over(partition by ash_time, pid) as max_level
                                from     search_wait_chain
                                where    level > 0
                                group by ash_time,
                                         level,
                                         pid,
                                         wait_event,
                                         path) as all_wait_chain
                where  level = max_level) as wait_chain
group by path,
         cnt
order by count(*) desc;" 2>/dev/null || usage
fi

