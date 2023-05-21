psql -d $database -U $user -c "select event_object_schema, event_object_table, trigger_schema, trigger_name, pg_get_triggerdef(oid) from information_schema.triggers it join pg_trigger t on it.trigger_name = t.tgname;"