#!/bin/bash

song_info=$(mpc status --format "%title% - %artist%" | head -n1)

echo "🎵 $song_info" 
