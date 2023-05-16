psql -d $database -U $user -c "with recursive partitions as
  (select inhrelid,
          inhparent
   from pg_inherits
   where inhparent =
       (select oid
        from parent)
   union select i.inhrelid,
                i.inhparent
   from pg_inherits i
   join partitions p on i.inhparent = p.inhrelid),
               parent as
  (select oid
   from pg_class
   where relname = 'table_name'),
               tableoids as
  (select oid
   from parent
   union select inhrelid as id
   from partitions)
select indexrelid::regclass,
       indrelid::regclass,
       indisunique,
       indisprimary,
       indisvalid
from pg_index
where indrelid in
    (select *
     from tableoids) ;"
