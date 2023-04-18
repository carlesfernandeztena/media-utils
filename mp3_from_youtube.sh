if [[ -z "$1" ]]; then
    echo "Usage: $0 <youtube url>"
else
    yt-dlp_linux -i --extract-audio --audio-format mp3 $1
fi
