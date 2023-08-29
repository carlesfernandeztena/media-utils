#!/bin/bash
if [ "$#" -lt 2 ]; then 
    echo "Usage: $(basename "$0") <v0.mp4> <v1.mp4> ... <vN.mp4> <out_concat.mp4>"
    exit 1
fi
length=$(($#-1))
OUT_FILE="${*: -1}"
for f in "${@:1:$length}"; do echo "file '$f'"; done > files.txt
ffpb -y -hide_banner -v warning -f concat -i files.txt "${OUT_FILE}"
rm files.txt

echo ":: Done!"
