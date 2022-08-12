#!/bin/bash
if [ "$#" -ne 1 ]; 
then 
    echo "Usage: `basename $0` video"
    echo "It will generate one video per segmented scene."
    exit -1
fi
VID=$1

scenedetect -i ${VID} detect-content split-video
