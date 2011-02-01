#!/bin/sh

NO_OF_WORKERS=5
CNT=0
while true
do
    setsid rake resque:work COUNT=5 QUEUE=* &
    CNT=$((CNT+1))
    [[ $CNT -eq $NO_OF_WORKERS ]] && exit 0
done
