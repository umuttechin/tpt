connect_opts=

[ -z $host ] || connect_opts+="-h $host "
[ -z $port] || connect_opts+="-P $port "
[ -z $pass_wd] || connect_opts+="-p $pass_wd "

echo $connect_opts
psql -d $database -U $user $connect_opts -c "select pronamespace::regnamespace, proname, pg_get_functiondef(oid) from pg_proc where pronamespace  in (select oid from pg_namespace where nspname not in ('pg_toast', 'pg_catalog', 'information_schema')) and proname != 'group_concat';"

