#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 <video_file> <vertical_size> \n"
    echo "Example: $0 video.mp4 480" 
    echo "          will produce video.mp4.gif of size [? x 480].\n"
    exit -1
fi
IN=$1
VSIZE=$2

ffmpeg -i $IN -vf "fps=10,scale=-1:${VSIZE}:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 ${IN}.gif
