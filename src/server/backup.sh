#!/bin/bash
#Creates a backup of the mysql database in its current state, and saves the last 4 backups to the backup_path specified below.
#This file should be in the path '/usr/local/bin/' according to the crontab rule for automatic backups and be given +x permissions.

#path to back up to
backup_path=/srv/backups
#number of OLD backups to keep
num_backups=3
for i in $(seq ${num_backups} -1 1)
do
  if [ -e "${backup_path}/backup_${i}.sql" ]
    then
    j=$((i+1))
    cp "${backup_path}/backup_${i}.sql" "${backup_path}/backup_${j}.sql"
  fi
done
mysqldump forum > "${backup_path}/backup_1.sql"
sed -i '1s/^/use forum;\n/' "${backup_path}/backup_1.sql"
