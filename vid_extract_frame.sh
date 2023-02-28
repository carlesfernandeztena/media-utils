#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: `basename $0` <video> <frame_number>"
    exit -1
fi
IN=$1
FRAME=$2

ffmpeg -i $IN  -vf "select=eq(n\,${FRAME})" -vframes 1 `basename $IN | sed 's/\(.*\)\..*/\1/'`.png

