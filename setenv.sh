#!/bin/bash

unset o OPTARG OPTIND database user

usage() { echo "Usage: source setenv -d <db_name> -u <username> [-p <password>] [-h <host>] [-P <port>]" 1>&2; }

while getopts ":d:u:h:P:p" o; do
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
        P)
            port=${OPTARG}
            ;;
        p)
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


export PAGER=less
export LESS='-iMFXSx4R'




export database=$database
export user=$user
[ -z "$host" ] || export host=$host
[ -z "$port" ] || export port=$port
[ -z "$pass_wd" ] || export pass_wd=$pass_wd

echo -e "\n"

