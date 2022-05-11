if [ "$#" -ne 3 ]; then 
    echo "Usage: $0 <file> <from xx:xx:xx> <length xx:xx:xx>"
    exit -1
fi
FILE=$1
START=$2
LEN=$3
ffmpeg -i $FILE -ss $START -t $LEN -async 1 -c:v libx265 -crf 26 -preset fast -c:a aac -b:a 128k ${FILE}.cut.mp4
