#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $(basename "$0") <video>"
    echo
    exit 1
fi
IN=$1
ffprobe -loglevel error -select_streams v:0 -show_entries packet=pts_time,flags -of csv=print_section=0 "$IN" | grep ",K"
DURATION=$(vid_duration.sh "$IN")
echo "(Video duration: $DURATION)"