psql -d $database -U $user -c "WITH configtab AS
(
       SELECT s.schemaname,
              c.relname,
              c.oid,
              c.relkind,
              s.n_dead_tup,
              s.n_mod_since_analyze,
              (c.reltuples * coalesce((
              SELECT Split_part(x, '=', 2) FROM   unnest(c.reloptions) q(x)
              WHERE  x LIKE 'autovacuum_analyze_scale_factor%'), current_setting('autovacuum_analyze_scale_factor'))::float8) +
              coalesce((SELECT split_part(x, '=', 2) FROM   unnest(c.reloptions) q(x)
              WHERE  x LIKE 'autovacuum_analyze_threshold%'), current_setting('autovacuum_analyze_threshold'))::float8 a_threshold,
              (c.reltuples * coalesce((SELECT split_part(x, '=', 2) FROM   unnest(c.reloptions) q(x)
              WHERE  x LIKE 'autovacuum_vacuum_scale_factor%'), current_setting('autovacuum_vacuum_scale_factor'))::float8) +
		      coalesce((SELECT split_part(x, '=', 2) FROM   unnest(c.reloptions) q(x)
              WHERE  x LIKE 'autovacuum_vacuum_threshold%'), current_setting('autovacuum_vacuum_threshold'))::float8 v_threshold
       FROM   pg_class c
       join   pg_stat_all_tables s
       ON     c.oid = s.relid)
SELECT schemaname,
       relname,
       oid,
       relkind,
       CASE WHEN n_mod_since_analyze > a_threshold THEN 'analyze' END AS candidate_analyze,
       CASE WHEN n_dead_tup > v_threshold THEN 'vacuum' END AS candite_vacuum
FROM   configtab;"
