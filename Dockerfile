FROM debian:buster as buildJanus

ARG JANUS_OPENSSL=--enable-openssl
ARG JANUS_BORINGSSL=--disable-boringssl
ARG JANUS_POST_PROCESSING=--enable-post-processing
ARG JANUS_DATA_CHANNELS=--disable-data-channels
ARG JANUS_DOCS=--disable-docs

ARG JANUS_TRANSPORT_REST=--enable-rest
ARG JANUS_TRANSPORT_WEBSOCKET=--enable-websockets
ARG JANUS_TRANSPORT_RABBIT_MQ=--disable-rabbitmq
ARG JANUS_TRANSPORT_MQTT=--disable-mqtt
ARG JANUS_TRANSPORT_UNIX_SOCKET=--disable-unix-sockets
ARG JANUS_TRANSPORT_NANOMSG=--disable-nanomsg

ARG JANUS_PLUGIN_AUDIOBRIDGE=--disable-plugin-audiobridge
ARG JANUS_PLUGIN_DUKTAPE=--disable-plugin-duktape
ARG JANUS_PLUGIN_ECHOTEST=--disable-plugin-echotest
ARG JANUS_PLUGIN_LUA=--disable-plugin-lua
ARG JANUS_PLUGIN_RECORDPLAY=--disable-plugin-recordplay
ARG JANUS_PLUGIN_SIP=--enable-plugin-sip
ARG JANUS_PLUGIN_NOSIP=--disable-plugin-nosip
ARG JANUS_PLUGIN_STREAMING=--disable-plugin-streaming
ARG JANUS_PLUGIN_TEXTROOM=--disable-plugin-textroom
ARG JANUS_PLUGIN_VIDEOCALL=--disable-plugin-videocall
ARG JANUS_PLUGIN_VIDEOROOM=--disable-plugin-videoroom
ARG JANUS_PLUGIN_VOICEMAIL=--disable-plugin-voicemail

ARG JANUS_LOGGERS_ALL=--disable-all-loggers
ARG JANUS_LOGGERS_JSON=--enable-json-logger

# Install Janus Dependencies 
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update \
  && apt-get -y upgrade \
  && apt-get -y remove --purge libgnutls28-dev \
  && apt-get -y install wget git build-essential cmake libmicrohttpd-dev libjansson-dev libssl-dev \
    libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    libconfig-dev pkg-config gengetopt libtool automake libnanomsg-dev gtk-doc-tools \
    python3 python3-pip python3-setuptools python3-wheel ninja-build \
    libavutil-dev libavcodec-dev libavformat-dev m4 \ 
    libconfig9 libglib2.0-0 libjansson4 libcurl4 liblua5.3 libmicrohttpd12 \
  && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata \
# Install Locales
  && apt-get install -y apt-utils locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen en_US.UTF-8 \
  && echo "LANG=en_US.UTF-8" > /etc/default/locale \
  && update-locale en_US.UTF-8 \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
# Install Sofia-SIP
  && cd /tmp/ && git clone --depth 1 https://github.com/ayty-adrianomartins/sofia-sip /tmp/sofia-sip \
  && cd /tmp/sofia-sip && ./autogen.sh && ./configure CFLAGS=-fPIC --prefix=/usr \
  && make && make install \ 
  && ldconfig \
# Install libnice
  && cd /tmp/ && git clone --depth 1 --single-branch --branch master https://github.com/ayty-adrianomartins/libnice /tmp/libnice \
  && cd /tmp/libnice && pip3 install meson && meson --prefix=/usr build && ninja -C build && ninja -C build install \
  # Install libsrtp
  && cd /tmp/ && wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz \
  && tar xfv v2.3.0.tar.gz && rm -rf v2.3.0.tar.gz && cd libsrtp-2.3.0 \
  && ./configure CFLAGS=-fPIC --prefix=/usr --enable-openssl \
  && make shared_library && make install \ 
  && rm -rf libsrtp-2.3.0 \
# Install libwebsockets
  && cd /tmp/ && git clone --depth 1 --single-branch -b v4.0-stable https://github.com/ayty-adrianomartins/libwebsockets.git /tmp/libwebsockets \
  && cd /tmp/libwebsockets && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
  && make && make install

# Install Janus Gateway
ADD . /tmp/janus-gateway
RUN cd /tmp/janus-gateway && sh autogen.sh \
  && ./configure --prefix=/ \
    # Janus configuration
    $JANUS_BORINGSSL \
    $JANUS_POST_PROCESSING \
    $JANUS_DATA_CHANNELS \
    $JANUS_DOCS \
    # Transport configuration
    $JANUS_TRANSPORT_REST \
    $JANUS_TRANSPORT_WEBSOCKET \
    $JANUS_TRANSPORT_RABBIT_MQ \
    $JANUS_TRANSPORT_MQTT \
    $JANUS_TRANSPORT_UNIX_SOCKET \
    # Plugins configuration
    $JANUS_PLUGIN_AUDIOBRIDGE \
    $JANUS_PLUGIN_ECHOTEST \
    $JANUS_PLUGIN_RECORDPLAY \
    $JANUS_PLUGIN_SIP \
    $JANUS_PLUGIN_NOSIP \
    $JANUS_PLUGIN_STREAMING \
    $JANUS_PLUGIN_TEXTROOM \
    $JANUS_PLUGIN_VIDEOCALL \
    $JANUS_PLUGIN_VIDEOROOM \
    $JANUS_PLUGIN_VOICEMAIL \
    $JANUS_PLUGIN_DUKTAPE \
    $JANUS_PLUGIN_LUA \
    # Loggers
    $JANUS_LOGGERS_ALL \
    $JANUS_LOGGERS_JSON \
  && make && make install && make configs

# Cleanup
RUN devpackages=`dpkg -l|grep '\-dev'|awk '{print $2}'|xargs` \
  && DEBIAN_FRONTEND=noninteractive apt-get -y remove --purge \
    wget git build-essential cmake libmicrohttpd-dev libjansson-dev libssl-dev \
    libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    libconfig-dev pkg-config gengetopt libtool automake libnanomsg-dev gtk-doc-tools \
    libavutil-dev libavcodec-dev libavformat-dev m4 \
    python3 python3-pip python3-setuptools python3-wheel ninja-build meson \
    ${devpackages} \
  && apt-get purge -y --auto-remove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

# Pack Image
FROM scratch
COPY --from=buildJanus / /

# Config
EXPOSE 7088/tcp 7089/tcp 8088/tcp 8089/tcp 8188/tcp 8189/tcp
VOLUME /etc/janus/ /share/janus/recordings/

# Start Script
ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
