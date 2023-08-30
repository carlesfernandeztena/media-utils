#!/bin/bash
echo
docker run ffmpeg -version
echo
echo "Use it like:"
echo "============"
echo "docker run -v \$(pwd):\$(pwd) -w \$(pwd) ffmpeg -v warning ..."
echo