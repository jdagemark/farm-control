#!/bin/bash
#
# Simple script that can be used to control pumps for an aeroponic farm
# the script toggles gpio pins on a raspberry pi
#

# default values
PUMP="8"
DURATION="180"
SOLENOID=""

function echo_log {
	echo "$1" | logger
}

# get input
print_usage() {
    echo "Usage: pump.sh --pump-pin <pin> --duration <seconds>"
    echo ""
    echo "Options:"
    echo " -h, --help"
    echo "    Print detailed help screen"
	echo " -p, --pump-pin"
	echo "    Which pin that controls the pump."
    echo " -d, --duration"
    echo "    Duration the pump should run in seconds."
    echo " -s, --solenoid"
    echo "    Which pin to open for 5 seconds in case the pump ran"
    echo "    dry the previous cycle."
    echo ""
    echo "Example:"
    echo "pump.sh --pump-pin 8 --duration 120 --solenoid 9"
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
        --solenoid)
            SOLENOID=$2
            shift
            ;;
        -s)
            SOLENOID=$2
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

# function for initializing pins
function gpio_initialize {
	echo "$1" > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio$1/direction
	echo "0" > /sys/class/gpio/gpio$1/value
    echo_log "Pin $1 initialized"
}

# function for deinitialize pins
function gpio_deinitialize {
    if [ -e /sys/class/gpio/gpio$1/value ] ; then
	    echo "0" > /sys/class/gpio/gpio$1/value
        echo "$1" > /sys/class/gpio/unexport
        echo_log "Pin $1 deinitialized"
    fi
}

# toggle gpio pin on
function gpio_on {
	echo "1" > /sys/class/gpio/gpio$1/value
}

# toggle gpio pin off
function gpio_off {
	echo "0" > /sys/class/gpio/gpio$1/value
}

# unexpected abort
function abort {
	gpio_deinitialize $PUMP
	echo_log "Pump on pin $PUMP aborted"
    if [ ! -z "$SOLENOID" ] ; then
        gpio_deinitialize $SOLENOID
        echo_log "Solenoid on pin $SOLENOID aborted"
    fi
	exit 255
}

trap abort SIGINT SIGTERM

# Do the work
gpio_initialize $PUMP
gpio_on $PUMP
echo_log "Pump on pin $PUMP on."

# toggle the solenoid (if set) to allow the pump to free-flow
# and "auto fix" issues when beeing ran dry.
if [ ! -z "$SOLENOID" ] ; then
    echo_log "Solenoid on pin $SOLENOID on."
    gpio_initialize $SOLENOID
    gpio_on $SOLENOID
    sleep 5
    gpio_off $SOLENOID
    gpio_deinitialize $SOLENOID
    echo_log "Solenoid on pin $SOLENOID is off."
    DURATION=$(($DURATION - 5))
fi

sleep $DURATION
gpio_off $PUMP
gpio_deinitialize $PUMP
echo_log "Pump on pin $PUMP off."
