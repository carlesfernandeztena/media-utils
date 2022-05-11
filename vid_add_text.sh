#!/bin/bash
if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 <text_label>"
    exit -1
fi
IN_VIDEO=$1
TEXT=$2

# how many vertical pixels
RES_Y=`ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 ${IN_VIDEO} | cut -dx -f2`

FONTSIZE=$((RES_Y/15))

ffmpeg -y -hide_banner -v warning -i ${IN_VIDEO} -vf "drawtext=fontfile=/path/to/font.ttf:text='$TEXT':fontcolor=white:fontsize=$FONTSIZE:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=4*(h-text_h)/5" -codec:a copy text_${IN_VIDEO}
