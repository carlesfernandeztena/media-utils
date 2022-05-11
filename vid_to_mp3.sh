#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 video"
    exit -1
fi
VID=$1

ffmpeg -i $VID -q:a 0 -map a ${VID}.mp3
