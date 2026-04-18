#!/bin/bash

# Default to wlp8s0 if no argument is provided
IFACE=${1:-wlp8s0}
PATH_RX="/sys/class/net/$IFACE/statistics/rx_bytes"
PATH_TX="/sys/class/net/$IFACE/statistics/tx_bytes"

while true; do
    # Read current byte counts
    OLD_RX=$(cat "$PATH_RX")
    OLD_TX=$(cat "$PATH_TX")
    
    sleep 1
    
    # Read new byte counts
    NEW_RX=$(cat "$PATH_RX")
    NEW_TX=$(cat "$PATH_TX")

    # Calculate difference and convert to KiB
    # (Bytes / 1024 = KiB)
    RX=$(( (NEW_RX - OLD_RX) / 1024 ))
    TX=$(( (NEW_TX - OLD_TX) / 1024 ))

    # Output with icons
    echo " ${RX} KiB/s   ${TX} KiB/s"
done
