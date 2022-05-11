#!/bin/bash
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then 
    echo    "
    USAGE: watermark.sh <video.mp4> [<secs_silence=4>] [<volume=0.5>] 
    
        <video>                       Input video file
        <secs_silence> (opt, def=4)   Silence seconds between watermarks
        <volume> (opt, def=0.5)       Volume of audio watermarks
    "
    exit -1
fi
IN_VIDEO=$1
if [ "$#" -gt 2 ]; then SECS_SIL=$3; else SECS_SIL=4; fi
if [ "$#" -gt 3 ]; then VOLUME=$3; else VOLUME=0.5; fi

# Input image + audio watermarking files
IMG_WM="vime_img_wm.png"
AU_WM1="vime_audio_wm1.wav"
AU_WM2="vime_audio_wm2.wav"

# Temporary audio file
TMP_VIDEO=$(mktemp _XXXXXXXX.mp4)
TMP_AUDIO=$(mktemp _XXXXXXXX.wav)

# Get resolutions of image watermark and input video
RES_VIDEO=`ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 ${IN_VIDEO}`

# Create base audio watermark composition to loop over video
ffmpeg -y -hide_banner  -f lavfi -t ${SECS_SIL} -i anullsrc=channel_layout=stereo:sample_rate=44100 -i ${AU_WM1} -i ${AU_WM2} -filter_complex "[0:a][1:a][0:a][2:a]concat=n=4:v=0:a=1" ${TMP_AUDIO}

# Single Filtergraph command to carry out img + audio watermarking
ffmpeg -y -hide_banner  -stream_loop -1 -i ${TMP_AUDIO} -i ${IN_VIDEO} -i ${IMG_WM} -shortest -filter_complex "[0:a]volume=${VOLUME}[aw];[1:a]volume=1.0[av];[aw][av]amix=inputs=2,volume=2;[2:v]scale=${RES_VIDEO} [scaled_wm],[1:v][scaled_wm]overlay=0:0" watermarked_${IN_VIDEO}
 
#ffmpeg -y -hide_banner -f lavfi -t ${SECS_SIL} -i anullsrc=channel_layout=stereo:sample_rate=44100 -i ${AU_WM1} -i ${AU_WM2} -i ${IN_VIDEO} -filter_complex "[0:a][1:a][0:a][2:a]concat=n=4:v=0:a=1,aloop=-1,volume=${VOLUME}[aw];[3:a]volume=1.0[av];[aw][av]amix=inputs=2:duration=shortest,volume=2" ${TMP_VIDEO}

#ffmpeg -y -hide_banner -i ${IN_VIDEO} -i ${IMG_WM} -i ${AU_WM1} -i ${AU_WM2} -f lavfi -t ${SECS_SIL} -i anullsrc=channel_layout=stereo:sample_rate=44100  -filter_complex "[1:v]scale=${RES_VIDEO} [scaled_wm],[0:v][scaled_wm]overlay=0:0;[4:a][2:a][4:a][3:a]concat=n=4:v=0:a=1,volume=${VOLUME}[aw];[aw]aloop=loop=10[loopaw];[0:a]volume=1.0[av];[av][loopaw]amix=inputs=2:duration=first,volume=2" watermarked_${IN_VIDEO}

ffmpeg -y -hide_banner -v warning -i ${TMP_VIDEO} -i ${IMG_WM} -filter_complex "[1:v]scale=${RES_VIDEO} [scaled_wm],[0:v][scaled_wm]overlay=0:0" watermarked_${IN_VIDEO}

rm -rf ${TMP_AUDIO} ${TMP_VIDEO}

