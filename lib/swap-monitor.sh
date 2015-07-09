#!/bin/bash
# Notify me one time if my swap is over MAXSWAP and log the
# swap usage as well in SWAPLOG.
# Usage: ./swap-monitor.sh &

SWAPLOG=~/coasst/data_entry/log/swap.log
MAXSWAP=25
INTERVAL=60

send_sms_msg () {
  if [ "$1" ]; then STRING=$1; fi
  if [ $SMS_SENT ]; then
    return 0
  else
    echo $STRING | mailx -s 'swap usage on coasst' 8055708714@txt.att.net
    SMS_SENT=1
  fi
}

while true; do
    # parse free output, get current swap value
    swaptest=`free -m |grep Swap|perl -pe 's/Swap:\s+\S+\s+(\S+).*/$1/'`
    echo `date` Swap is: $swaptest >> $SWAPLOG
    if [ $swaptest -ge $MAXSWAP ]; then
        send_sms_msg "Swap is: $swaptest MB"
    fi;
    sleep $INTERVAL
done;
