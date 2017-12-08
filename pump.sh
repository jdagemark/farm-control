#!/bin/bash

pump="8"
duration="180"

logfile=/var/log/indoor-farm.log

date=`date "+%F %R:%S"`
echo "$date Pump starting" >> $logfile


# initialize pins
echo "$pump" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$pump/direction
pumpstate="/sys/class/gpio/gpio$pump/value"
echo "0" > $pumpstate

# toggle the pump
echo "1" > $pumpstate
sleep $duration
echo "0" > $pumpstate

# deinitialize
echo "$pump" > /sys/class/gpio/unexport

date=`date "+%F %R:%S"`
echo "$date Pump finished" >> $logfile

