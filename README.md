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

A basic local connection is:

```
source setenv.sh -d postgres -u postgres -w
```

will ask your user' s password. In addition, the default approach is using a hostname a port number, so every connection will
trigger a host connection depending on your pg_hba file rules. So, you might want to delete host and port entries for a local
connection and relevant entries from setenv.sh script to make permanent.

The database queries:

```-h``` will always help you about the usage of the script.

```./aas_ash.sql -h
Usage Examples:
./aas_ash.sql
./ass_ash.sql "'$time_interval'"
```
![Alt text](images/aas_ash_example_5.png?raw=true "Optional Title" )







``````

``````
