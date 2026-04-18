#!/bin/bash

if  killall wf-recorder; then
    notify-send -u normal -i media-record "Recording Stopped" "Saving recording to: /home/subh/Videos/recordings/video.mkv"
else
    exit 1
fi
