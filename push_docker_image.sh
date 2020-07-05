#!/bin/sh

if [[ $1 = "debug" ]]
then
    docker tag softphone_janus_debug docker.aytytech.com/softphone_webrtc_janus:latest_debug
    docker tag softphone_janus_debug docker.aytytech.com/softphone_webrtc_janus:v2.0_debug
    docker login -u="aytytech" -p="ayty@2020" docker.aytytech.com
    docker push docker.aytytech.com/softphone_webrtc_janus:latest_debug
    docker push docker.aytytech.com/softphone_webrtc_janus:v2.0_debug
else
    docker tag softphone_janus docker.aytytech.com/softphone_webrtc_janus:latest
    docker tag softphone_janus docker.aytytech.com/softphone_webrtc_janus:v2.0
    docker login -u="aytytech" -p="ayty@2020" docker.aytytech.com
    docker push docker.aytytech.com/softphone_webrtc_janus:latest
    docker push docker.aytytech.com/softphone_webrtc_janus:v2.0
fi