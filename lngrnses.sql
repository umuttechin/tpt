psql -d $database -U $user -c "SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  state,
  'SELECT pg_cancel_backend('||pid||');',
  query  
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';"
