#!/bin/sh

if [[ $1 = "debug" ]]
then
    docker tag softphone_janus_debug download.aytytech.com/softphone_webrtc_janus:latest_debug
    docker tag softphone_janus_debug download.aytytech.com/softphone_webrtc_janus:v2.1_debug
    docker login -u="admin" -p="tNyDrxFwrJ6do2Zj" download.aytytech.com
    docker push download.aytytech.com/softphone_webrtc_janus:latest_debug
    docker push download.aytytech.com/softphone_webrtc_janus:v2.1_debug
else
    docker tag softphone_janus download.aytytech.com/softphone_webrtc_janus:latest
    docker tag softphone_janus download.aytytech.com/softphone_webrtc_janus:v2.1
    docker login -u="admin" -p="tNyDrxFwrJ6do2Zj" download.aytytech.com
    docker push download.aytytech.com/softphone_webrtc_janus:latest
    docker push download.aytytech.com/softphone_webrtc_janus:v2.1
fi