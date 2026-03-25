#!/bin/bash

IFACE=${1:-wlp8s0}

while true; do
    OLD=$(awk -v i="$IFACE:" '$1==i {print $2, $10}' /proc/net/dev)
    sleep 1
    NEW=$(awk -v i="$IFACE:" '$1==i {print $2, $10}' /proc/net/dev)

    OLD_RX=$(echo $OLD | awk '{print $1}')
    OLD_TX=$(echo $OLD | awk '{print $2}')
    NEW_RX=$(echo $NEW | awk '{print $1}')
    NEW_TX=$(echo $NEW | awk '{print $2}')

    RX=$(( (NEW_RX - OLD_RX) / 1024 ))
    TX=$(( (NEW_TX - OLD_TX) / 1024 ))

    echo "↓ ${RX} KB/s  ↑ ${TX} KB/s"
done
