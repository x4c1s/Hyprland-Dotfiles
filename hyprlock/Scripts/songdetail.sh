#!/bin/bash

mpd_info="$(mpc current --format "🎵 %artist% - %title%" 2>/dev/null)"
if [ $? -eq 0 ]; then
    echo "$mpd_info"
fi

player_info="$(playerctl metadata --format '▶️  {{artist}} - {{title}}' 2>/dev/null)"
if [ $? -eq 0 ]; then
   echo $player_info
fi
 
