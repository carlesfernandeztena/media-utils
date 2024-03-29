#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo -e "Usage: $(basename "$0") <video_file> <vertical_size> \n"
    echo -e "Example: $(basename "$0") video.mp4 480" 
    echo -e "          will produce video.mp4.gif of size [? x 480].\n"
    exit 1
fi
IN=$1
VSIZE=$2

ffmpeg -i "$IN" -vf "fps=10,scale=-1:${VSIZE}:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${IN}.gif"
