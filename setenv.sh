#!/bin/bash

unset o OPTARG OPTIND database user host port pass_wd

usage() { echo "Usage: source setenv -d <db_name> -u <username> [-w <password>] [-h <host>] [-p <port>]" 1>&2; }

while getopts ":d:u:h:p:w" o; do
    case "${o}" in
        d)
            database=${OPTARG}
            ;;
        u)
            user=${OPTARG}
            ;;
        h)
            host=${OPTARG}
            ;;	
        p)
            port=${OPTARG}
            ;;
        w)
            read -s -r -p "Password: " pass_wd
            ;;			
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${database}" ] || [ -z "${user}" ]; then
    usage
fi

echo "[uts]" > ./.pg_service.conf

#export database=$database
#export user=$user

echo "dbname=$database"  >> ./.pg_service.conf 
echo "user=$user"  >> ./.pg_service.conf 

[ -z "$host" ] && echo "host=localhost"  >> ./.pg_service.conf || echo "host=$host"  >> ./.pg_service.conf 
[ -z "$port" ] && echo "port=5432"  >> ./.pg_service.conf || echo "port=$port"  >> ./.pg_service.conf
[ -z "$pass_wd" ] || echo "password=$pass_wd" >> ./.pg_service.conf


export PGSERVICE=uts
export PGSERVICEFILE=./.pg_service.conf
export PAGER=less
export LESS='-iMFXSx4R'


echo -e "\n"

