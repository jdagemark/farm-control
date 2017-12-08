#!/bin/bash

pump="8"
solenoid="11"

# initialize pins
echo "$pump" > /sys/class/gpio/export
echo "$solenoid" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$pump/direction
echo "out" > /sys/class/gpio/gpio$solenoid/direction
pumpstate="/sys/class/gpio/gpio$pump/value"
solenoidstate="/sys/class/gpio/gpio$solenoid/value"
echo "0" > $pumpstate
echo "0" > $solenoidstate

# toggle the pump
echo "1" > $pumpstate
echo "Pump is on"
sleep 10
echo "0" > $pumpstate
echo "Pump is off"

# toggle the solenoid
sleep 2
echo "1" > $solenoidstate
echo "Solenoid is on"
sleep 2
echo "0" > $solenoidstate
echo "Solenoid is off"

# deinitialize
echo "$pump" > /sys/class/gpio/unexport
echo "$solenoid" > /sys/class/gpio/unexport
