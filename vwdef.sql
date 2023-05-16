psql -d $database -U $user -c "select view_definition from information_schema.views where table_schema = 'information_schema' and table_name = 'routines';"
