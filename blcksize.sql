psql -d $database -U $user -c "SELECT current_setting('block_size') as block_size;"
