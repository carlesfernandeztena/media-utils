#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 input output.webm"
    exit -1
fi
IN=$1
OUT=$2

ffmpeg -i $IN -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 $OUT
