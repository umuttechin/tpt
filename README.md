## TPT

This repository mainly aims to ease PostgreSQL administration on command line.
There are hundreds, thousands queries and tools for analyzing and solving problems.
Yet, sometimes we have no other choices except command line, and there are lots of people who
loves to use command line. I am one of them and using some scripts make it much more fun.

Tanel Poder' s scripts saves so much time for Oracle database systems, yet there was no equivalent
of it in PostgreSQL. Here is a basic collection of ash scripts(from Bertrand Drouvot' s pgsentinel) and some others.

Let' s start!

In order to begin to use scripts we need to prepare a psql database connection.

```
./setenv.sh -h
Usage: source setenv.sh -d <db_name> -u <username> [-w <password>] [-h <host>] [-p <port>]
```

A basic connection is:

```
source setenv.sh -d postgres -u postgres -w
```

will ask your user' s password. In addition, the default approach is using a hostname a port number, so every connection will
trigger a host connection depending on your pg_hba file rules. So, you might want to delete host and port entries for a local
connection and relevant entries from setenv.sh script to make permanent.

The database queries:

```-h``` will always help you about the usage of the script.

For average active session(aas):

```./aas_ash.sql -h
Usage Examples:
./aas_ash.sql
./ass_ash.sql "'$time_interval'"
```
![Alt text](images/aas_ash_example_1.png?raw=true "Optional Title" )

To find the query that has most aas on the ash:

```
./meq_ash.sql -h
./meq_ash.sq
./meq_ash.sq "time interval = '$time_interval'"
```

Or, if you want to write your own predicates for different result set:

```
./ash.sql -h
Usage Examples:
./ash.sql
./ash.sql "$cols $predicate $date1 $date2
./ash.sql wait_event 1=1 "now()-interval '15 minutes'"  "now()"
./ash.sql wait_event "datname='pgbench'" "now()-interval '15 minutes'" "now()"
```

For example;

```
./ash.sql usename,wait_event "datname='postgres'" "now()-interval '15 minutes'" "now()"
```

![Alt text](images/aas_ash_example_2.png?raw=true "Optional Title" )







``````
