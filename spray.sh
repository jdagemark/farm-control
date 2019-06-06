#!/bin/bash
#
# Simple script that can be used to control spray intervalls for
# an aeroponic farm. The script toggles gipo pins on a raspberry pi.
#

# default values
SPRAY="11"
DURATION="3"

function echo_log {
    echo "$1" | logger
}

# get input
print_usage() {
    echo "Usage: spray.sh --spray-pin 11 --duration 5"
    echo ""
    echo "Options:"
    echo " -h, --help"
    echo "    Print detailed help screen"
    echo " -p, --spray-pin"
    echo "    Which pin that controls the spray."
    echo " -d, --duration"
    echo "    Duration the spray should run in seconds."
    echo ""
    echo "Example:"
    echo "spray.sh --spray-pin 11 --duration 5"
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
        --spray-pin)
            SPRAY=$2
            shift
            ;;
        -p)
            SPRAY=$2
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

echo_log "Spray on pin $SPRAY starting"

# function for initializing the pins
function spray_initialize {
    echo "$SPRAY" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio$SPRAY/direction
    echo "0" > /sys/class/gpio/gpio$SPRAY/value
}

# function for deinitialize the pins
function spray_deinitialize {
    echo "0" > /sys/class/gpio/gpio$SPRAY/value
    echo "$SPRAY" > /sys/class/gpio/unexport
}

# start spray
function spray_start {
    echo "1" > /sys/class/gpio/gpio$SPRAY/value
}

# stop spray
function spray_stop {
    echo "0" > /sys/class/gpio/gpio$SPRAY/value
}

# unexpected abort
function abort {
    spray_deinitialize
    echo_log "Spray on pin $SPRAY aborted"
    exit 255
}

trap abort SIGINT SIGTERM

# Do the work
spray_initialize
spray_start
sleep $DURATION
spray_stop
spray_deinitialize

echo_log "Spray on pin $SPRAY finished"
