#!/bin/bash

function docker_mediautils() {
    docker run -it --rm -v "$(pwd)":"$1" -w "$1" media-utils "${@:2}"
}
function docker_mediautils_cuda() {
    docker run -it --rm --gpus all -v "$(pwd)":"$1" -w "$1" media-utils-cuda "${@:2}"
}

echo "Creating environment aliases to access the docker commands"
(
    cd scripts || exit 0
    for script in *
    do
        echo "- ${script%.*}, ${script%.*}_cuda"
        alias ${script%.*}="docker_mediautils /directory $script"
        alias ${script%.*}_cuda="docker_mediautils_cuda /directory $script"
    done
)
echo "All successfully created :)"