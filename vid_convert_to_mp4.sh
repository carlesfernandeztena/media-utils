#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: `basename $0` input output.mp4"
    exit -1
fi
IN=$1
OUT=$2

ffmpeg -i $IN -vcodec libx264 -preset slow -crf 18 $OUT
