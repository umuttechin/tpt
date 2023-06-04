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
