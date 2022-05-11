#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 input"
    exit -1
fi
IN=$1

LEVEL=12

# 0x7be8a0
ffmpeg -y -hide_banner -i $1 -vf chromakey=0x7be8a0:0.${LEVEL} -c:v png -pix_fmt yuva420p -crf 18 ${1%.*}_${LEVEL}.mov

ffmpeg -y -hide_banner -i ${1%.*}_${LEVEL}.mov -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 ${1%.*}_${LEVEL}.webm

#ffmpeg -y -hide_banner -i ${1%.*}.mov -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 -filter:v "crop=1080:1080:424:0" ${1%.*}.webm
#ffmpeg -y -hide_banner -i ${1%.*}.mov -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 -filter:v "crop=700:700:620:24" ${1%.*}_crop.webm

rm ${1%.*}_${LEVEL}.mov
