#!/bin/bash
if [ "$#" -lt 3 -o "$#" -gt 4 ]; then 
    echo "Usage: $0 <vid1> <vid2> <out_vid> [\"up\"/\"down\"]"
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
    ffmpeg -hide_banner -y -i $IN_VIDEO1 -f lavfi -i anullsrc -vcodec copy -acodec aac -shortest audio_$IN_VIDEO1
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
ffmpeg -y  \
  -i ${IN_VIDEO1} \
  -i ${IN_VIDEO2} \
  -filter_complex "[1:v][0:v]scale2ref=oh*mdar:ih[1v][0v];
                   [0v][1v]vstack=2,scale='2*trunc(iw/2)':'2*trunc(ih/2)'[vid]" \
  -map '[vid]'  -c:v libx264 -crf 18 -preset ultrafast -map 0:a -vsync 2 \
    ${TMP}

echo " :: Adding labels to mosaic"
ffmpeg -hide_banner -y \
    -i ${TMP} \
    -vf "drawtext=fontfile=/path/to/font.ttf:text='${TEXT1}':fontcolor=white:fontsize=72:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=1*(h-text_h)/6+h/9, \
        drawtext=fontfile=/path/to/font.ttf:text='${TEXT2}':fontcolor=white:fontsize=72:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=3*(h-text_h)/6+h/9" \
    -codec:a copy \
    -codec:v libx264 -crf 18 -preset ultrafast -vsync 2 \
    ${OUT_VIDEO}
    
rm -rf $TMP
rm -rf audio_$IN_VIDEO1

echo ":: Created ${OUT_VIDEO}"
