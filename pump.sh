#!/bin/bash

# default values
PUMP="8"
DURATION="180"

function echo_log {
	echo "$1" | logger
}

# get input
print_usage() {
        echo "Usage: pump.sh --pump-pin 8 --duration 120"
        echo ""
        echo "Options:"
        echo " -h, --help"
        echo "    Print detailed help screen"
	echo " -p, --pump-pin"
	echo "    Which pin that controls the pump."
        echo " -d, --duration"
        echo "    Duration the pump should run in seconds."
        echo ""
        echo "Example:"
        echo "pump.sh --duration 120"
        echo ""
}

# Make sure the correct number of command line
# arguments have been supplied

if [ $# -lt 1 ]; then
        print_usage
        exit 3
fi

# read input variables
while test -n "$1"; do
    case "$1" in
        --help)
            print_usage
            exit 0
            ;;
        -h)
            print_usage
            exit 0
            ;;
        --pump-pin)
            PUMP=$2
            shift
            ;;
        -p)
            PUMP=$2
            shift
            ;;
        --duration)
            DURATION=$2
            shift
            ;;
        -d)
            DURATION=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit 3
            ;;
    esac
    shift
done

echo_log "Pump on pin $PUMP starting"

# function for initializing the pins
function pump_initialize {
	echo "$PUMP" > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio$PUMP/direction
	echo "0" > /sys/class/gpio/gpio$PUMP/value
}

# function for deinitialize the pins
function pump_deinitialize {
	echo "0" > /sys/class/gpio/gpio$PUMP/value
        echo "$PUMP" > /sys/class/gpio/unexport
}

# start pump
function pump_start {
	echo "1" > /sys/class/gpio/gpio$PUMP/value
}

# stop pump
function pump_stop {
	echo "0" > /sys/class/gpio/gpio$PUMP/value
}

# unexpected abort
function abort {
	pump_deinitialize
	echo_log "Pump on pin $PIN aborted"
	exit 255
}

trap abort SIGINT SIGTERM

# Do the work
pump_initialize
pump_start
sleep $DURATION
pump_stop
pump_deinitialize

echo_log "Pump on pin $PUMP finished"
