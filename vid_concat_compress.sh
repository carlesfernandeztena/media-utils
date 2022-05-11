#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <dir_videos>"
    exit -1
fi
DIR=$1
if [ ! -d $DIR ]; then
    echo "Dir does not exist: $DIR"
    exit -1
fi
if [ ${DIR: -1} == '/' ]; then
    DIR=${DIR::-1}
fi
for f in `ls $DIR`; do echo "file '${DIR}/$f'"; done > files.txt
ffmpeg -f concat -i files.txt -c:v libx265 -crf 26 -preset fast -c:a aac -b:a 128k $DIR.mp4
rm files.txt
echo ":: Done!"
