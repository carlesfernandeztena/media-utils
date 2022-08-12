#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: `basename $0` <video>"
    echo "Will extract the first frame into <same_basename>.png."
    exit -1
fi
IN=$1

ffmpeg -c:v libvpx-vp9 -i ${IN} -frames:v 1 ${IN}.png