#!/bin/bash
maxcpu=0
maxmem=0
while true
do
    json=$(docker stats "$(docker ps -n 1 -q)" --no-stream --format json)
    
    # ID
    id=$(echo "$json" | jq '.ID' | cut -d\" -f2)
    
    # CPU 
    cpu=$(echo "$json" | jq '.CPUPerc' | cut -d\" -f2 | cut -d% -f1)
    cpu=${cpu%%*( )} # trim spaces
    cpuint=$(echo "$cpu" | cut -d. -f1)
    
    # Memory
    mem=$(echo "$json" | jq '.MemUsage' | cut -d\" -f2 | cut -d/ -f1)
    mem=${mem%%*( )} # trim spaces
    if [ "${mem: -4:3}" == "MiB" ]; then
        memint=${mem/MiB/}
        memint=$(echo "$memint" | cut -d. -f1)
    elif [ "${mem: -4:3}" == "GiB" ]; then
        memint=${mem/GiB}
        memint=${memint/"."}
    else 
        echo "none"
    fi
    
    # Keep maximum values
    if [ $((memint > maxmem)) ]; then maxmem=$((memint)); fi
    if [ $((cpuint > maxcpu)) ]; then maxcpu=$((cpuint)); fi
    
    echo "$id CPU=$cpu MEM=$mem (Max: $maxcpu threads, $maxmem MB)"
    sleep 1
done