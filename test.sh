#! /bin/sh

if [ $# -ne 1 ]; then
    echo 'docker-in.sh requires a minimum of 1 argument.' 1>&2
    echo 'Usage:  build-slave.sh <two-digit>' 1>&2
    exit 1
fi

if [ $(expr length $1) -ne 2 ]; then
    echo 'Argument must be 2-digit number.' 1>&2
    exit 1
fi

if [ $1 = '00' ]; then
    echo 'Argument must be other than 00' 1>&2
    exit 1
fi

NAME=hadoop-$1

LINE=$(docker ps -f name=$NAME | wc -l)

if [ $LINE -ge 2 ]; then
    echo "$NAME exits already." 1>&2
    exit 1
fi

echo $NAME
