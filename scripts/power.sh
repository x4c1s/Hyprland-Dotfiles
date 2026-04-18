#!/bin/bash

choice=$(printf "⏻ Shutdown\n Reboot\n Suspend\n Lock\n󰍃 Logout" | rofi -dmenu -p "Power:")

case "$choice" in
  "⏻ Shutdown") systemctl poweroff ;;
  " Reboot") systemctl reboot ;;
  " Suspend") systemctl suspend ;;
  " Lock") hyprlock -c /home/subh/.config/hyprlock/hyprlock.conf ;; 
  "󰍃 Logout") loginctl kill-session $(loginctl list-sessions | grep tty | awk -F " " '{print $1}') ;;
esac
