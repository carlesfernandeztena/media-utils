#!/bin/bash
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then 
    echo "Usage: $0 <folder with videos> [\"up\"/\"down\"]"
    echo "  up: title in the upper section"
    echo "  down: title in the lower section"
    exit 1
fi
FOLDER="$1"
TEXT_WHERE="$2"

if [ "${FOLDER: -1}" == '/' ]; then
    FOLDER=${FOLDER::-1}
fi
V=( $(ls "$FOLDER") )
NUM_VIDEOS=${#V[@]}
rows=$(echo "${NUM_VIDEOS}" | awk '{print int(sqrt($1))}');
#rows=$(echo "sqrt($NUM_VIDEOS)" | bc); # awk is more present than bc in servers
cols=$(((NUM_VIDEOS+rows-1)/rows)) # ceil operation
V1=${V[0]}

#################################################################
echo " :: Found ${NUM_VIDEOS} videos -> ${rows} x ${cols}"
#echo " :: Checking for audio track"
#################################################################
HAS_AUDIO=$(ffprobe -i "${FOLDER}/${V1}" -show_streams -select_streams a -loglevel error)
if [ ${#HAS_AUDIO} == 0 ]
then 
    echo "No audio track detected, adding silent track..."
    ffmpeg -y -hide_banner -v warning -i "${FOLDER}/${V1}" -f lavfi -i anullsrc -vcodec copy -acodec aac -shortest "${FOLDER}/_audio"
    IN_VIDEO1_MOD="_audio"
else
    IN_VIDEO1_MOD="${V1}"
fi

#################################################################
echo " :: Extracting video faces from each one"
#################################################################
mkdir -p "facecrop_${FOLDER}"
for (( i=0; i<NUM_VIDEOS; i++ ));
do
	eval vid_face_crop.sh "${FOLDER}/${V[i]}"
done

#################################################################
#echo " :: Getting filename stems as labels"
#################################################################
declare -a STEMS
for (( i=0; i<NUM_VIDEOS; i++ ));
do
	STEMS[i]="${V[i]}"
done
EXTENSION="${V1##*.}"
TMP=$(mktemp "XXXXXX.${EXTENSION}")

declare -a X Y POS_X POS_Y
for (( i=0; i<NUM_VIDEOS; i++ ));
do
	X[i]=$((i%cols))
    Y[i]=$((i/cols))
    POS_X[i]="($((2*X[i]+1))*w/2-text_w)/${cols}"
    if [ "$TEXT_WHERE" == "down" ]; then
        POS_Y[i]="(h-text_h)*$((5+Y[i]*6))/$((6*rows))"
    else
        POS_Y[i]="(h-text_h)*$((1+Y[i]*6))/$((6*rows))"
    fi
done


W=300
H=300
TOT_W=$((W*cols))
TOT_H=$((H*rows))

#################################################################
echo " :: Creating video mosaic"
#################################################################
CMD="ffmpeg -y -hide_banner -v warning "
CMD+="-i facecrop_${FOLDER}/${IN_VIDEO1_MOD} " # add the first one with audio track
for (( i=1; i<NUM_VIDEOS; i++ )); do
    CMD+="-i facecrop_${FOLDER}/${V[i]} "
done
CMD+="-filter_complex \"nullsrc=size=${TOT_W}x${TOT_H} [base]; "
for (( i=0; i<NUM_VIDEOS; i++ )); do
    CMD+="[${i}:v] setpts=PTS-STARTPTS, scale=${W}x${H} [v${i}]; "
done
CMD+="[base][v0] overlay=shortest=1 [tmp0]; "
for (( i=1; i<NUM_VIDEOS-1; i++ )); do
    x=$((i%cols))
    y=$((i/cols))
    CMD+="[tmp$((i-1))][v${i}] overlay=shortest=1:x=$((x*W)):y=$((y*H)) [tmp${i}]; "
done
x=$((NUM_VIDEOS%cols))
y=$((NUM_VIDEOS/cols))
CMD+="[tmp$((NUM_VIDEOS-1))][v${NUM_VIDEOS}] overlay=shortest=1:x=$((x*W)):y=$((y*H)) \" "
CMD+="-c:v libx264 -crf 18 -preset veryfast -map 0:a  ${TMP}"
eval "${CMD}"

#################################################################
echo " :: Adding labels to mosaic"
#################################################################
OUT_VIDEO="mosaic_${FOLDER}.${EXTENSION}"
CMD="ffmpeg -hide_banner -loglevel error -y -i ${TMP} -vf \""
FONTFILE="/usr/share/fonts/truetype/freefont/FreeSans.ttf"
for (( i=0; i<NUM_VIDEOS; i++ )); do
    CMD+="drawtext=fontfile=${FONTFILE}:text='${STEMS[i]}':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=${POS_X[i]}:y=${POS_Y[i]}, "
done
CMD+="\" -codec:a copy -codec:v libx264 -crf 18 -preset veryfast ${OUT_VIDEO}"
eval "${CMD}"
rm -rf "$TMP" "${FOLDER}/audio" "facecrop_${FOLDER}"

echo " :: Created ${OUT_VIDEO}"
