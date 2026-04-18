#!/bin/bash

ffmpeg -y -i $1 -an -c:v libx264 -preset medium -crf 21 -movflags +faststart -b:v 3M -maxrate 4.5M -bufsize 6M -vf scale=-1:1080 /tmp/compressed.mp4
