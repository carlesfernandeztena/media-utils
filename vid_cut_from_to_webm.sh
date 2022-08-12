if [ "$#" -ne 4 ]; then 
    echo "Usage: `basename $0` <file.webm> <from xx:xx:xx> <to xx:xx:xx> <newfile.webm>"
    exit -1
fi
FILE=$1
START=$2
END=$3
NEWFILE=$4
ffmpeg -c:v libvpx-vp9 -i $FILE -ss $START -to $END -async 1 -c:v libvpx-vp9 -pix_fmt yuva420p -crf 18 ${NEWFILE}
