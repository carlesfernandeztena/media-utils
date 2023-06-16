#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $(basename "$0") <IN> <COLOR> <OUT>"
    echo "Example: $(basename "$0") input.webm 0xFFFFFF output.mp4"
    exit 1
fi
IN=$1
COLOR=$2
OUT=$3

ffmpeg -y -hide_banner -loglevel error \
    -c:v libvpx-vp9 -i "${IN}" \
    -f lavfi -i color=c="${COLOR}",format=rgb24 \
    -filter_complex "[1][0]scale2ref[bg][vid];[bg][vid]overlay=format=rgb:shortest=1,setsar=1" \
    -pix_fmt yuv420p -c:v libvpx-vp9 "${OUT}"