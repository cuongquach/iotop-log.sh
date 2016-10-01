#!/bin/bash
# Script log IO process
# Author : Quach Chi Cuong
# Time cycle to remove old log : 7 days
# Crontab : * * * * * root /path/iotop-logging.sh

#### USAGE ####
# Install iotop if it is not exist
# CentOS/RedHat : yum install -y iotop
# Ubuntu : sudo apt-get install -y iotop

## Variable settings
DATE=$(date +%Y-%m-%d)
OLD_DATE=$(date --date="7 days ago" +%Y-%m-%d)
YESTERDAY_DATE=$(date --date="yesterday" +%Y-%m-%d)
MIDNIGHT=$(date +%H)
CURRENT_IO_LOG=/var/log/iotop.${DATE}.log
OLD_IO_LOG=/var/log/iotop.${OLD_DATE}.log
YESTERDAY_IO_LOG=/var/log/iotop.${YESTERDAY_DATE}.log
TIMER=0

## Function delete old backup. I dont use logrotate
delete_old_log()
{
        if [ -f ${OLD_IO_LOG} ];then
                rm -f ${OLD_IO_LOG}
        fi
}

compress_yesterday_log()
{
     if [ -f ${YESTERDAY_IO_LOG} ];then
          gzip -9 ${YESTERDAY_IO_LOG}
     fi
}

## Main action
checking()
{
        if [ ! -d /var/log/ ];then
                mkdir -p /var/log/
        fi

        # Delete old log at 01 AM every day
        if [[ ${MIDNIGHT} == "01" ]];then
               delete_old_log
               compress_yesterday_log
        fi
}



### Main functions ###
checking

iotop -bqqqotk -n 61 >> ${CURRENT_IO_LOG} &
PID_IOTOP=$(echo $!)

while [ ${TIMER} -lt 59 ]
do
        sleep 1
        ((TIMER++))
done

## Kill PID of iotop
kill -9 ${PID_IOTOP}

exit 0