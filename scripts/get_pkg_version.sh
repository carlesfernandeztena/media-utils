#!/bin/bash
if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <package>"
    exit 1
fi
dpkg -l | grep '^ii' | grep "$1" | awk '{print $2=$3}'