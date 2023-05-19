#!/bin/bash

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":d:u:h:P:p:" o; do
    case "${o}" in
        d)
            database=${OPTARG}
            ;;
        u)
            user=${OPTARG}
            ;;
        h)
            host=${OPTARG}
            export host=$host
            ;;	
        P)
            port=${OPTARG}
            export port=$port
            ;;
        p)
            #passwd=read_password
            read -s -p "Password: " pass_wd
            export pass_wd=$pass_wd
            ;;			
        *)
            usage
            ;;
    esac
done
#shift $((OPTIND-1))

if [ -z "${database}" ] || [ -z "${user}" ]; then
    usage
fi


export PAGER=less
export LESS='-iMFXSx4R'
export $database
export $user
exit 0
