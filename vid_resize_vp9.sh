#!/bin/bash
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then 
    echo "Usage: $0 video W_new H_new [output_name]"
    exit -1
fi
VID=$1
W=$2
H=$3
OUT=resized_$VID
if [ "$#" -eq 4 ]
then
    OUT=$4
fi

ffmpeg -c:v libvpx-vp9 -i $VID -vf scale=$W:$H -crf 18 $OUT
