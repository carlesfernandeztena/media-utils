#!/bin/bash
if [ "$#" -ne 1 ]; 
then 
    echo "Usage: $(basename "$0") video"
    exit 1
fi

ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$1"
