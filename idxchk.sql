psql -d $database -U $user -c "select
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_name,
	am.amname as access_method,
	-- a.attnum  as attribute_num,
	-- ix.indkey::text as index_key,;
	-- unnest(ix.indkey),
	array_position(ix.indkey, a.attnum) as index_order
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a,
	pg_am am
where
    t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
	and i.relam = am.oid
    and t.relname like '%table_name%'
order by
    t.relname,
    i.relname,
	index_order;"
