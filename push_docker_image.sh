#!/bin/sh

if [[ $1 = "debug" ]]
then
    docker tag softphone_janus_debug download.aytytech.om/softphone_webrtc_janus:latest_debug
    docker tag softphone_janus_debug download.aytytech.om/softphone_webrtc_janus:v2.0_debug
    docker login -u="aytytech" -p="ayty@2020" download.aytytech.om
    docker push download.aytytech.om/softphone_webrtc_janus:latest_debug
    docker push download.aytytech.om/softphone_webrtc_janus:v2.0_debug
else
    docker tag softphone_janus download.aytytech.om/softphone_webrtc_janus:latest
    docker tag softphone_janus download.aytytech.om/softphone_webrtc_janus:v2.0
    docker login -u="aytytech" -p="ayty@2020" download.aytytech.om
    docker push download.aytytech.om/softphone_webrtc_janus:latest
    docker push download.aytytech.om/softphone_webrtc_janus:v2.0
fi