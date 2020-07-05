#!/bin/sh

set -e

# Admin API
if [ -n "$JANUS_ADM_SECRET_KEY" ]
then
    sed -i "s/admin_http = false/admin_http = true/g" /etc/janus/janus.transport.http.jcfg
    sed -i "s/admin_secret = \"janusoverlord\"/admin_secret = \"${JANUS_ADM_SECRET_KEY}\"/g" /etc/janus/janus.jcfg
fi

# Janus Log
if [ -n "$JANUS_DEBUG_LEVEL" ]
then
    ARGS="${ARGS} -d ${JANUS_DEBUG_LEVEL}"
fi

if [ "$JANUS_LOG_TO_FILE" = true ]
then
    ARGS="${ARGS} -L /share/janus/logs"
fi

if [ "$JANUS_LOG_DISABLE_STDOUT" = true ]
then
    ARGS="${ARGS} -N"
fi

# Janus ICE
if [ -n "$JANUS_ICE_ENFORCE_LIST" ]
then
    ARGS="${ARGS} -E ${JANUS_ICE_ENFORCE_LIST}"
    sed -i "s/ice_ignore_list = \"vmnet\"/#ice_ignore_list = \"vmnet\"/g" /etc/janus/janus.jcfg
fi

if [ "$JANUS_USE_STUN" = true ] && [ -n "$JANUS_STUN_SERVER" ] && [ -n "$JANUS_STUN_SERVER_PORT" ]
then
    ARGS="${ARGS} -S ${JANUS_STUN_SERVER}:${JANUS_STUN_SERVER_PORT}"
fi

if [ "$JANUS_USE_TURN" = true ] && [ -n "$JANUS_TURN_SERVER" ] && [ -n "$JANUS_TURN_SERVER_PORT" ] && [ -n "$JANUS_TURN_SERVER_USER" ] && [ -n "$JANUS_TURN_SERVER_PASS" ]
then
    sed -i "s/#turn_server = \"myturnserver.com\"/turn_server = \"${JANUS_TURN_SERVER}\"/g" /etc/janus/janus.jcfg
    sed -i "s/#turn_port = 3478/turn_port = \"${JANUS_TURN_SERVER_PORT}\"/g" /etc/janus/janus.jcfg
    sed -i "s/#turn_type = \"udp\"/turn_type = \"udp\"/g" /etc/janus/janus.jcfg
    sed -i "s/#turn_user = \"myuser\"/turn_user = \"${JANUS_TURN_SERVER_USER}\"/g" /etc/janus/janus.jcfg
    sed -i "s/#turn_pwd = \"mypassword\"/turn_pwd = \"${JANUS_TURN_SERVER_PASS}\"/g" /etc/janus/janus.jcfg
fi

if [ "$JANUS_FULL_TRICKLE" = true ]
then
    ARGS="${ARGS} -f"
fi

if [ "$JANUS_ICE_LITE" = true ]
then
    ARGS="${ARGS} -I"
fi

# Janus Options
if [ -n "$SERVER_DOMAIN" ]
then
    container_name=`hostname`
    ARGS="${ARGS} -n \"${SERVER_DOMAIN}-${container_name}\""
fi

if [ -n "$JANUS_SESSION_TIMEOUT" ]
then
    ARGS="${ARGS} -s ${JANUS_SESSION_TIMEOUT}"
fi

if [ -n "$JANUS_SLOWLINK_THRESHOLD" ]
then
    ARGS="${ARGS} -W ${JANUS_SLOWLINK_THRESHOLD}"
fi

if [ -n "$RTP_PORT_RANGE_MIN" ] && [ -n "$RTP_PORT_RANGE_MAX" ]
then
    ARGS="${ARGS} -r ${RTP_PORT_RANGE_MIN}-${RTP_PORT_RANGE_MAX}"
fi

# SIP Plugin
if [ "$JANUS_BEHIND_NAT" = true ]
then
    sed -i "s/behind_nat = false/behind_nat = true/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ -n "$SIP_SDP_IP" ]
then
    sed -i "s/#sdp_ip = \"1.2.3.4\"/sdp_ip = \"${SIP_SDP_IP}\"/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ -n "$SIP_KEEPALIVE_INTERVAL" ]
then
    sed -i "s/keepalive_interval = 120/keepalive_interval = ${SIP_KEEPALIVE_INTERVAL}/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ -n "$SIP_USER_AGENT_STRING" ]
then
    sed -i "s/# user_agent = \"Cool WebRTC Gateway\"/user_agent = \"${SIP_USER_AGENT_STRING}\"/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ -n "$SIP_REGISTER_TTL" ]
then
    sed -i "s/register_ttl = 3600/register_ttl = ${SIP_REGISTER_TTL}/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ "$SIP_EVENTS" = true ]
then
    sed -i "s/#events = false/events = ${SIP_EVENTS}/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ "$SIP_EVENTS" = true ]
then
    sed -i "s/#events = false/events = ${SIP_EVENTS}/g" /etc/janus/janus.plugin.sip.jcfg
fi

if [ -n "$RTP_PORT_RANGE_MIN" ] && [ -n "$RTP_PORT_RANGE_MAX" ]
then
    sed -i "s/rtp_port_range = \"20000-40000\"/rtp_port_range = \"${RTP_PORT_RANGE_MIN}-${RTP_PORT_RANGE_MAX}\"/g" /etc/janus/janus.plugin.sip.jcfg
fi

# Event Handler
if [ "$EVENT_HANDLER_ENABLE" = true ] && [ -n "$EVENT_HANDLER_EVENTS" ] && [ -n "$EVENT_HANDLER_BACKEND" ] && [ -n "$EVENT_HANDLER_BACKEND_USER" ] && [ -n "$EVENT_HANDLER_BACKEND_PWD" ]
then
    ARGS="${ARGS} -e"
    sed -i "s/enabled = false/enabled = ${EVENT_HANDLER_ENABLE}/g" /etc/janus/janus.eventhandler.sampleevh.jcfg
    sed -i "s/events = \"all\"/events = \"${EVENT_HANDLER_EVENTS}\"/g" /etc/janus/janus.eventhandler.sampleevh.jcfg
    sed -i "s#backend = \"http://your.webserver.here/and/a/path\"#backend = \"${EVENT_HANDLER_BACKEND}\"#g" /etc/janus/janus.eventhandler.sampleevh.jcfg
fi

if [ -n "$EVENT_HANDLER_BACKEND_USER" ] && [ -n "$EVENT_HANDLER_BACKEND_PWD" ]
then
    sed -i "s/#backend_user = \"myuser\"/backend_user = \"${EVENT_HANDLER_BACKEND_USER}\"/g" /etc/janus/janus.eventhandler.sampleevh.jcfg
    sed -i "s/#backend_pwd = \"mypwd\"/backend_pwd = \"${EVENT_HANDLER_BACKEND_PWD}\"/g" /etc/janus/janus.eventhandler.sampleevh.jcfg
fi

if [ -n "$ARGS" ]
then

    # Disable Plugins
    sed -i "s/#disable = \"libjanus_voicemail.so,libjanus_recordplay.so\"/disable = \"libjanus_streaming.so,libjanus_voicemail.so,libjanus_videoroom.so,libjanus_videocall.so,libjanus_textroom.so,libjanus_streaming.so,libjanus_nosip.so,libjanus_lua.so,libjanus_audiobridge.so,libjanus_duktape.so,libjanus_echotest.so,libjanus_voicemail.so,libjanus_recordplay.so\"/g" /etc/janus/janus.jcfg
    # Disable Transports
    sed -i "s/#disable = \"libjanus_rabbitmq.so\"/disable = \"libjanus_rabbitmq.so,libjanus_nanomsg.so,libjanus_pfunix.so\"/g" /etc/janus/janus.jcfg
    # Disable Loggers
    sed -i "s/#disable = \"libjanus_jsonlog.so\"/disable = \"libjanus_jsonlog.so\"/g" /etc/janus/janus.jcfg

    # Correções no Arquivo
    sed -i "s#= \"//#= \"/#g" /etc/janus/janus.jcfg

    ARGS="${ARGS} --cert-pem /etc/janus/cert.pem --cert-key /etc/janus/privkey.pem"

fi

# Start Janus
exec /bin/janus $ARGS