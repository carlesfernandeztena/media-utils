#!/bin/bash
OUT_FILENAME=tiles.png
if [ "$#" -lt 2 ]; then 
    echo "Usage: $(basename "$0") <tiles> <img1> ... <imgN>"
    echo
    echo "Will generate an output called ${OUT_FILENAME}."
    echo "Use MxN to define the tiles, e.g. 1x2 or 2x2."
    echo "Examples: "
    echo "      $(basename "$0") 3x1 i1.png i2.jpg i3.jpeg"
    echo "      $(basename "$0") 2x2 img_0*"
    echo
    exit 1
fi
TILES=$1

#using imagemagick's montage for this
montage "${@:2}" -tile "${TILES}" -geometry +0+0 ${OUT_FILENAME}