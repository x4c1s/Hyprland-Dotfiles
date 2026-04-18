#!/bin/bash

timer() {
    local seconds=$1
    while [ $seconds -gt 0 ]; do
        MIN=$(printf "%02d" $((seconds / 60)))
        SEC=$(printf "%02d" $((seconds % 60)))
        
        echo -ne "\r󰔟 $MIN:$SEC"
        
        sleep 1
        seconds=$((seconds - 1))
    done
    
    notify-send -u "critical" "🔔 TIME'S UP!"
}

main () {
    tmpfile=$(mktemp) 
    foot -a floatpattern -w 60x3 sh -c "read -p 'Enter mins: ' val; echo \$val > $tmpfile"

    MINS=$(cat "$tmpfile")
    rm "$tmpfile" 

    if [[ -n "$MINS" && "$MINS" =~ ^[0-9]+$ ]]; then
        TOTAL_SECONDS=$((MINS * 60))
        timer $TOTAL_SECONDS
    else
        echo "Invalid input or window closed."
    fi
}
main
