
#!/bin/bash

WALL_DIR="$HOME/wallpapers"

choices=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) \
	| sort \
        | rofi -dmenu -i -p "Pick wallpaper")

[ -z "$choices" ] && exit
awww img "$choices" \
	--transition-fps 60 \
	--transition-type any


