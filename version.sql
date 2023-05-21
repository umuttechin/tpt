psql -c "SELECT current_setting('cluster_name') as cluster_name, current_setting('server_version') as server_version, version();"
