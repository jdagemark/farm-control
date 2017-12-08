#!/bin/bash

solenoid="11"
duration="4"


logfile=/var/log/indoor-farm.log

date=`date "+%F %R:%S"`
echo "$date Spray starting" >> $logfile

# initialize pins
echo "$solenoid" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$solenoid/direction
solenoidstate="/sys/class/gpio/gpio$solenoid/value"
echo "0" > $solenoidstate

# toggle the solenoid
echo "1" > $solenoidstate
sleep $duration
echo "0" > $solenoidstate

# deinitialize
echo "$solenoid" > /sys/class/gpio/unexport

date=`date "+%F %R:%S"`
echo "$date Spray finished" >> $logfile
