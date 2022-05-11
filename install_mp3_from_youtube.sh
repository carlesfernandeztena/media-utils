echo ":: Installing youtube-dl..."
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
echo ":: Updating apt-get..."
sudo apt-get update -q
echo ":: Installing python, ffmpeg..."
sudo apt install -y python ffmpeg
