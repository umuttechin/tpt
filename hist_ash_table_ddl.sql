CREATE TABLE public.pg_hist_active_session_history (
    snap_time timestamp with time zone,
    ash_time timestamp with time zone,
    datid oid,
    datname text,
    pid integer,
    leader_pid integer,
    usesysid oid,
    usename text,
    application_name text,
    client_addr text,
    client_hostname text,
    client_port integer,
    backend_start timestamp with time zone,
    xact_start timestamp with time zone,
    query_start timestamp with time zone,
    state_change timestamp with time zone,
    wait_event_type text,
    wait_event text,
    state text,
    backend_xid xid,
    backend_xmin xid,
    top_level_query text,
    query text,
    cmdtype text,
    queryid bigint,
    backend_type text,
    blockers integer,
    blockerpid integer,
    blocker_state text
);

CREATE TABLE public.pg_hist_stat_statements_history (
    snap_time timestamp with time zone,
    ash_time timestamp with time zone,
    userid oid,
    dbid oid,
    queryid bigint,
    calls bigint,
    total_exec_time double precision,
    rows bigint,
    shared_blks_hit bigint,
    shared_blks_read bigint,
    shared_blks_dirtied bigint,
    shared_blks_written bigint,
    local_blks_hit bigint,
    local_blks_read bigint,
    local_blks_dirtied bigint,
    local_blks_written bigint,
    temp_blks_read bigint,
    temp_blks_written bigint,
    blk_read_time double precision,
    blk_write_time double precision,
    plans bigint,
    total_plan_time double precision,
    wal_records bigint,
    wal_fpi bigint,
    wal_bytes numeric
);


--0,30 * * * * psql -U postgres -f /usr/postgres/postgresql_ash.sql
--0,30 * * * * psql -U postgres -f /usr/postgres/postgresql_stats.sql

--cat /usr/postgres/postgresql_ash.sql
--insert into pg_hist_active_session_history SELECT Now(), ash_time, datid, datname, pid, leader_pid, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_start, xact_start, query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin, top_level_query, query, cmdtype, queryid, backend_type, blockers, blockerpid, blocker_state FROM pg_active_session_history WHERE  Trunc(Extract(second FROM ash_time))::int % 10 = 0 AND ash_time > Now() - interval '30 minutes';
--cat /usr/postgres/postgresql_stats.sql
--insert into pg_hist_stat_statements_history SELECT Now(), ash_time, userid, dbid, queryid, calls, total_exec_time, rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, blk_read_time, blk_write_time, plans, total_plan_time, wal_records, wal_fpi, wal_bytes FROM pg_stat_statements_history WHERE Trunc(Extract(second FROM ash_time))::int % 10 = 0 AND ash_time > Now() - interval '30 minutes'
