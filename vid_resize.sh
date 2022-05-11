#!/bin/bash
if [ "$#" -ne 3 ]; then 
    echo "Usage: $0 video W_new H_new"
    exit -1
fi
VID=$1
W=$2
H=$3

ffmpeg -i $VID -vf scale=$W:$H -preset slow -crf 18 resized_$VID
