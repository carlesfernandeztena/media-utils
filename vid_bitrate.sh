#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $(basename "$0") <video>"
    echo
    exit 1
fi
IN=$1
BITRATE=$(ffprobe -i "$IN" -v 0 -show_entries format=bit_rate -of compact=p=0:nk=1)
echo "Video bitrate: ${BITRATE}"
