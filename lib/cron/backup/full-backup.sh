#!/usr/bin/env bash

# timestamp containing he year and current month, so we generate a new
# backup each week
WEEKYEAR=`date +%Y-%W`
# retain last 60 days worth of backups
LENGTH_TO_KEEP=60
BACKUP_DIR=/backup
tar vp --exclude=/proc --exclude=/usr --exclude=/lost+found --exclude=/backup --exclude=/home/scw/photos --exclude=/mnt --exclude=/sys --exclude /var/cache -c / | pigz -p 2 -c > ${BACKUP_DIR}/backup-${WEEKYEAR}.tar.gz

# delete old backups
find ${BACKUP_DIR} -mtime +60 -exec rm {} \;
