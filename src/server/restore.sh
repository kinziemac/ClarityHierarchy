#!/bin/bash
#Restores a mysql server database backup from the path specified below
#arguments: an integer, specifying the backup number from newest(1) to oldest(4 by default)

#path where the backups are contained
backup_path=/srv/backups

if [ -e ${backup_path}/backup_${1}.sql ]
then
  mysql < ${backup_path}/backup_${1}.sql
else
  echo "Failed to restore backup: backup ${1} does not exist in ${backup_path}."
fi
