#!/bin/bash

chosen=$(cat ~/.local/share/larbs/emoji | rofi -dmenu | sed "s/ .*//") 

[ -z "$chosen" ] && exit

printf "%s" "$chosen" | wl-copy
notify-send "'$chosen' copied to clipboard." 
