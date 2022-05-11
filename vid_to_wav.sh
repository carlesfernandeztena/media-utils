#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 <IN_VIDEO> <OUT_AUDIO>"
    exit -1
fi
IN_VIDEO=$1
OUT_AUDIO=$2
ffmpeg -i $IN_VIDEO -c copy -map 0:a $OUT_AUDIO
echo ":: Done!"