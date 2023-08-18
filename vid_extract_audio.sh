#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $(basename "$0") <video>"
    echo "(will get you the same filename with .mp3 extension)"
    exit 1
fi
IN=$1
FILENAME=$(basename -- "$IN")
ffmpeg -i "$IN" -q:a 0 -map a "${FILENAME%.*}.mp3"


