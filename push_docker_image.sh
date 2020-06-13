#!/bin/sh
docker tag janus docker.aytytech.com/softphone_webrtc_janus:v1.0
docker login -u="aytytech" -p="aytytech" docker.aytytech.com
docker push docker.aytytech.com/softphone_webrtc_janus:v1.0