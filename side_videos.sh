#!/bin/bash
if [ "$#" -lt 3 -o "$#" -gt 4 ]; then 
    echo "Usage: $0 <in_video1> <in_video2> <out_video> [\"up\"/\"down\"]"
    echo "  up: title in the upper section"
    echo "  down: title in the lower section"
    exit -1
fi
IN_VIDEO1=$1
IN_VIDEO2=$2
OUT_VIDEO=$3

echo " :: Checking for audio track"
HAS_AUDIO=`ffprobe -i $IN_VIDEO1 -show_streams -select_streams a -loglevel error`
if [ ${#HAS_AUDIO} == 0 ]
then 
    echo "No audio track detected, adding silent track..."
    ffmpeg -i $IN_VIDEO1 -f lavfi -i anullsrc -vcodec copy -acodec aac -shortest audio_$IN_VIDEO1
    IN_VIDEO1_MOD=audio_$IN_VIDEO1
else
    IN_VIDEO1_MOD=$IN_VIDEO1
fi

echo " :: Getting filenames as labels"
EXTENSION="${IN_VIDEO1##*.}"
TEXT1=${IN_VIDEO1%.*}
TEXT2=${IN_VIDEO2%.*}
TMP="tmpfile69.${EXTENSION}"
if [ $5 == "up" ]; then
    POS_Y="1*(h-text_h)/6"
else
    POS_Y="5*(h-text_h)/6"
fi

echo " :: Getting video mosaic" # -hide_banner -loglevel error
ffmpeg -hide_banner -loglevel error \
  -i ${IN_VIDEO1_MOD} \
  -i ${IN_VIDEO2} \
  -filter_complex '[0:v]pad=iw*2:ih[int];[int][1:v]overlay=W/2:0[vid]' \
  -map '[vid]' -c:v libx264 -crf 23 -preset veryfast \
  -map 1:a \
    ${TMP}


echo " :: Adding labels to mosaic"
ffmpeg -hide_banner -loglevel error -y \
    -i ${TMP} \
    -vf "drawtext=fontfile=/path/to/font.ttf:text='${TEXT1}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=(1*w/2-text_w)/2:y=${POS_Y}, \
        drawtext=fontfile=/path/to/font.ttf:text='${TEXT2}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=(3*w/2-text_w)/2:y=${POS_Y}" \
    -codec:a copy \
    -codec:v libx264 -crf 18 -preset slow \
    ${OUT_VIDEO}
    
rm -rf $TMP
rm -rf audio_$IN_VIDEO1

echo ":: Created ${OUT_VIDEO}"
