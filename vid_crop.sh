#!/bin/bash
if [ "$#" -ne 5 ]; then 
    echo "Usage: `basename $0` video startx starty w h"
    exit -1
fi
VID=$1
X=$2
Y=$3
W=$4
H=$5

ffmpeg -i $VID -filter:v "crop=$W:$H:$X:$Y" -c:a copy cropped_$VID
