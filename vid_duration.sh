#!/bin/bash
if [ "$#" -ne 1 ]; 
then 
    echo "Usage: `basename $0` video"
    exit -1
fi
VID=$1

ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${VID}
