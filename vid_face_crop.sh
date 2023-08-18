#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $(basename "$0") video"
    exit 1
fi
VID=$1

num_frames=$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$VID")

ffmpeg -y -hide_banner -v warning -i "$VID"  -vf "select=eq(n\,$((num_frames/2)))" -frames:v 1 _tmp.png
bbox=( $(face_detect.py _tmp.png) )
X=${bbox[0]}
Y=${bbox[1]}
W=${bbox[2]}
rm _tmp.png
echo "Found face: x=${X} y=${Y} w=${W}"
ffmpeg -y -hide_banner -v warning -i "$VID" -filter:v "crop=$W:$W:$X:$Y" -c:a copy "facecrop_$VID"
