#!/bin/bash

bookmark=$(wl-paste -p)
filename="$HOME/.local/share/larbs/bookmarks"


if [[ "$bookmark" =~ ^https?:// ]]; then
    if grep -q "^$bookmark$" "$filename"; then
        notify-send "Bookmark Status" "Already Bookmarked"
    else
        notify-send "Bookmark Status" "Bookmark Added"
        echo "$bookmark" >> "$filename"
    fi
else
    exit 1
fi
