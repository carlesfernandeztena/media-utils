#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $(basename "$0") <filename>.<ext>"
    echo "Output will be <filename>_bitrate.mp4"
    echo
    exit 1
fi
IN=$1
FILENAME="${IN%.*}"
# Print old bitrate
OLD_BITRATE=$(ffprobe -i "$IN" -v 0 -show_entries format=bit_rate -of compact=p=0:nk=1)
echo "Old bitrate: ${OLD_BITRATE} ($IN)"

# Convert bitrate
EXT="${IN##*.}"
OUTPUT="${FILENAME}_higher_bitrate.${EXT}"
#ffmpeg -y -hide_banner -v warning -i "${IN}" -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 "$OUTPUT"
ffmpeg -y -hide_banner -v warning -i "${IN}" -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 1.1M -minrate 1.1M -maxrate 1.1M -bufsize 2M  "$OUTPUT"

# Print new bitrate
NEW_BITRATE=$(ffprobe -i "$OUTPUT" -v 0 -show_entries format=bit_rate -of compact=p=0:nk=1)
echo "New bitrate: ${NEW_BITRATE} ($OUTPUT)"

