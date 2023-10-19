#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Add seconds of silence to a given audio file."
    echo "Usage: $(basename "$0") <audio_file> <seconds>"
    exit 1
fi
AUDIO_FILE=$1
SECONDS=$2
ffmpeg -f lavfi -t "$SECONDS" -i "$AUDIO_FILE" -i anullsrc=channel_layout=stereo:sample_rate=44100 -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1" "silence_${AUDIO_FILE}"