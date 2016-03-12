#!/bin/sh

if [ $# -ne 1 ]; then
    echo 'docker-in.sh requires a minimum of 1 argument.' 1>&2
    echo 'Usage:  docker-in.sh <container_name_or_ID>'
    exit 1
fi

PID=$(docker inspect --format {{.State.Pid}} $1)
sudo nsenter --target $PID --mount --uts --ipc --net --pid
