psql -d $database -U $user -c "SELECT schema_name,
       SUM(table_size) :: bigint / 1024 AS schema_size_in_kb,
       round(( SUM(table_size) / Pg_database_size(Current_database()) ) * 100, 2) AS
       percentage
FROM   (SELECT pg_catalog.pg_namespace.nspname           AS schema_name,
               Pg_relation_size(pg_catalog.pg_class.oid) AS table_size
        FROM   pg_catalog.pg_class
               join pg_catalog.pg_namespace
                 ON relnamespace = pg_catalog.pg_namespace.oid) t
GROUP  BY rollup(schema_name)
ORDER  BY 2 DESC; "
