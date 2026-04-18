#!/bin/bash

[[ "$(nmcli -g WIFI general)" == "disabled" ]] && nmcli radio wifi on

NETWORKS=$(nmcli -f SSID,SIGNAL,SECURITY dev wifi list | tail -n +2 | \
awk -F '  +' '
    $1 != "" {
        display = sprintf("%s (%s%%) [%s]", $1, $2, $3)
        print display
    }
' | sort -u)  

CHOICE=$(echo "$NETWORKS" | rofi -dmenu -i -p "WiFi:")
[[ -z "$CHOICE" ]] && exit 0

SSID=$(echo "$CHOICE" | sed 's/ (.*//')

BSSID=$(nmcli -t -f BSSID,SIGNAL dev wifi list | grep "^.*:$SSID$" | \
awk -F: '{print $1}' | sort -nr | head -n1)

[[ -z "$BSSID" ]] && BSSID="$SSID"

if nmcli dev wifi connect "$BSSID" 2>/dev/null; then
    notify-send -u normal -i network-wireless "WiFi Status" "$SSID Connected Successfully"
else
    PASSWORD=$(rofi -dmenu -password -p "Password for $SSID")
    [[ -z "$PASSWORD" ]] && exit 1
    nmcli dev wifi connect "$BSSID" password "$PASSWORD" && \
        notify-send -u normal -i network-wireless "WiFi Status" "$SSID Connected Successfully"
fi

