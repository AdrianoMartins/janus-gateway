#!/bin/sh
chmod 777 docker-entrypoint.sh

if [[ $1 = "debug" ]]
then
    docker build . -f Dockerfile-Debug -t softphone_janus_debug
else
    docker build . -f Dockerfile -t softphone_janus
fi