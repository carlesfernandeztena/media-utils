#!/bin/bash
if [ "$#" -lt 5 -o "$#" -gt 6 ]; then 
    echo "Usage: $0 <vid1> <vid2> <vid3> <vid4> <out_vid> [\"up\"/\"down\"]"
    echo "  up: title in the upper section"
    echo "  down: title in the lower section"
    exit -1
fi
IN_VIDEO1="$1"
IN_VIDEO2="$2"
IN_VIDEO3="$3"
IN_VIDEO4="$4"
OUT_VIDEO="$5"

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
TEXT3=${IN_VIDEO3%.*}
TEXT4=${IN_VIDEO4%.*}
TMP="tmpfile69.${EXTENSION}"
if [ $6 == "up" ]; then
    POS_Y1="1*(h-text_h)/12" # /6 and /2
    POS_Y2="7*(h-text_h)/12"
else
    POS_Y1="5*(h-text_h)/12"
    POS_Y2="11*(h-text_h)/12"
fi
POS_X1="(1*w/2-text_w)/2"
POS_X2="(3*w/2-text_w)/2"

echo " :: Getting video mosaic" # -hide_banner -loglevel error
ffmpeg -y  \
  -i "${IN_VIDEO1_MOD}" \
  -i "${IN_VIDEO2}" \
  -i "${IN_VIDEO3}" \
  -i "${IN_VIDEO4}" \
  -filter_complex "[0:v][1:v][2:v][3:v]xstack=inputs=4:layout=0_0|w0_0|0_h0|w0_h0[v]" -map "[v]" \
  -c:v libx264 -crf 18 -preset slow \
  -map 0:a \
    ${TMP}
#  -filter_complex "[1:v][0:v]scale2ref=oh*mdar:ih[1v][0v];[2:v][0v]scale2ref=oh*mdar:ih[2v][0v];[0v][1v][2v]hstack=3,scale='2*trunc(iw/2)':'2*trunc(ih/2)'[vid]" \

echo " :: Adding labels to mosaic"
ffmpeg -hide_banner -loglevel error -y \
    -i ${TMP} \
    -vf "drawtext=fontfile=/path/to/font.ttf:text='${TEXT1}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=${POS_X1}:y=${POS_Y1}, \
        drawtext=fontfile=/path/to/font.ttf:text='${TEXT2}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=${POS_X2}:y=${POS_Y1}, \
        drawtext=fontfile=/path/to/font.ttf:text='${TEXT3}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=${POS_X1}:y=${POS_Y2}, \
        drawtext=fontfile=/path/to/font.ttf:text='${TEXT4}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=${POS_X2}:y=${POS_Y2}" \
    -codec:a copy \
    -codec:v libx264 -crf 18 -preset slow \
    ${OUT_VIDEO}
    
rm -rf $TMP
rm -rf audio_$IN_VIDEO1

echo ":: Created ${OUT_VIDEO}"
