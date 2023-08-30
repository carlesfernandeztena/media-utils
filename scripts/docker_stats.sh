#!/bin/bash
if [ "$#" -ne 1 ]; then 
    CONTAINER_ID=$(docker ps -n 1 -q)
fi
docker stats "${CONTAINER_ID}"
while 1
do
    json=$(docker stats "$(docker ps -n 1 -q)" --no-stream --format json)
    # cpu 
    cpu=$(echo "$json" | jq '.CPUPerc')
    # memory and convert
    mem=$(echo "$json" | jq '.MemUsage' | cut -d\" -f2 | cut -d/ -f1)
    mem=${mem/MiB/}
    mem=${mem/GiB/*1000}
    sleep 1
done