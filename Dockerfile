# Build the server binary
FROM alpine:latest AS builder

COPY ./patches /tmp/patches

RUN apk update \
    && apk -U add --no-cache \
        autoconf \
        bash \
        build-base \
        binutils-gold \
        ca-certificates \
        cmake \
        git \
        glslang \
        jq \
        libarchive-tools \
        libstdc++ \
        linux-headers \
        ninja-build \
        openssl-dev \
        wget \
        xz \
        yasm \
    && export PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/sbin:/usr/lib/ninja-build/bin \
    && mkdir -p /server/lib /tmp/yuzu/build /tmp/yuzu/room /tmp/yuzu/mainline \
    && cd /tmp/yuzu \
    && wget -c "https://github.com/K4rian/docker-yuzu-room/releases/download/v0.1734/multiplayer-dedicated.tar.gz" -O multiplayer-dedicated.tar.xz \
    && wget -c "https://github.com/K4rian/docker-yuzu-room/releases/download/v0.1734/mainline-1734.tar.gz" -O mainline.tar.xz \
    && tar --strip-components=1 -xf multiplayer-dedicated.tar.xz -C /tmp/yuzu/room \
    && tar --strip-components=1 -xf mainline.tar.xz -C /tmp/yuzu/mainline \
    && cp /tmp/patches/*.patch /tmp/yuzu/room/patches 2>/dev/null \
    && cd /tmp/yuzu/mainline \
    && git apply /tmp/yuzu/room/patches/*.patch \
    && cd /tmp/yuzu/room/.ci \
    && bash deps.sh \
    && cd /tmp/yuzu/build \
    && { echo "#!/bin/ash"; \
         echo "LDFLAGS=\"-flto -fuse-linker-plugin -fuse-ld=gold\""; \
         echo "CFLAGS=\"-ftree-vectorize -flto\""; \
         echo "if [[ \"$(uname -m)\" == \"aarch64\" ]]; then"; \
         echo "  CFLAGS=\"-O2\""; \
         echo "  LDFLAGS=\"\""; \
         echo "elif [[ \"$(uname -m)\" == \"x86_64\" ]]; then"; \
         echo "  CFLAGS=\"$CFLAGS -march=core2 -mtune=intel\""; \
         echo "fi"; \
         echo "export CFLAGS"; \
         echo "export CXXFLAGS=\"$CFLAGS\""; \
         echo "export LDFLAGS"; \
         echo "cmake ../mainline -GNinja -DCMAKE_BUILD_TYPE=Release \\"; \
         echo " -DENABLE_SDL2=OFF -DENABLE_QT=OFF -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF \\"; \
         echo " -DUSE_DISCORD_PRESENCE=OFF -DYUZU_USE_BUNDLED_FFMPEG=ON -DYUZU_TESTS=OFF \\"; \
         echo " -DENABLE_LIBUSB=OFF"; \
         echo "ninja yuzu-room"; \
       } >/tmp/yuzu/build/build.sh \
    && chmod +x /tmp/yuzu/build/build.sh \
    && /tmp/yuzu/build/build.sh \
    && cp /tmp/yuzu/build/bin/yuzu-room /server/yuzu-room \
    && strip /server/yuzu-room \
    && chmod +x /server/yuzu-room \
    && cp /usr/lib/libgcc_s.so.1 /server/lib/libgcc_s.so.1 \
    && cp /usr/lib/libstdc++.so.6 /server/lib/libstdc++.so.6 \
    && echo -e "YuzuRoom-BanList-1" > /server/bannedlist.ybl \
    && touch /server/yuzu-room.log \
    && rm -R /tmp/yuzu /tmp/patches

# Set-up the server
FROM alpine:latest

ENV USERNAME=yuzu
ENV USERHOME=/home/$USERNAME

# Required
ENV YUZU_BINDADDR="0.0.0.0"
ENV YUZU_PORT=24872
ENV YUZU_ROOMNAME="yuzu Room"
ENV YUZU_PREFGAME="Any"
ENV YUZU_MAXMEMBERS=4
ENV YUZU_BANLISTFILE="bannedlist.ybl"
ENV YUZU_LOGFILE="yuzu-room.log"
# Optional
ENV YUZU_ROOMDESC=""
ENV YUZU_PREFGAMEID="0"
ENV YUZU_PASSWORD=""
ENV YUZU_ISPUBLIC=0
ENV YUZU_TOKEN=""
ENV YUZU_WEBAPIURL=""

RUN apk update \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=$USERNAME /server/ $USERHOME/
COPY --chown=$USERNAME ./container_files/ $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]