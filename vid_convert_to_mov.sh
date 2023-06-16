#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $(basename "$0") input.webm output.mov"
    exit 1
fi
IN=$1
OUT=$2

ffmpeg -c:v libvpx-vp9  -i "$IN" -c:v prores_ks -q 30 -pix_fmt yuva444p10le -crf 18 "$OUT"

