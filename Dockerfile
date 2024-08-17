FROM alpine:3.20 AS builder

COPY ./patches /tmp/patches

WORKDIR /tmp/yuzu

RUN apk update \
    && apk -U add --no-cache \
        autoconf=2.72-r0 \
        bash=5.2.26-r0 \
        build-base=0.5-r3 \
        binutils-gold=2.42-r0 \
        ca-certificates=20240705-r0 \
        cmake=3.29.3-r0 \
        git=2.45.2-r0 \
        glslang=1.3.261.1-r0 \
        jq=1.7.1-r0 \
        libarchive-tools=3.7.4-r0 \
        libstdc++=13.2.1_git20240309-r0 \
        linux-headers=6.6-r0 \
        ninja-build=1.12.1-r0 \
        openssl-dev=3.3.1-r3 \
        wget=1.24.5-r0 \
        xz=5.6.2-r0 \
        yasm=1.3.0-r4 \
    && export PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/sbin:/usr/lib/ninja-build/bin \
    && mkdir -p /server/lib /tmp/yuzu/build /tmp/yuzu/room /tmp/yuzu/mainline \
    && wget --show-progress -q -c -O "multiplayer-dedicated.tar.xz" "https://github.com/K4rian/docker-yuzu-room/releases/download/v0.1734/multiplayer-dedicated.tar.gz" \
    && wget --show-progress -q -c -O "mainline.tar.xz" "https://github.com/K4rian/docker-yuzu-room/releases/download/v0.1734/mainline-1734.tar.gz" \
    && tar --strip-components=1 -xf multiplayer-dedicated.tar.xz -C /tmp/yuzu/room \
    && tar --strip-components=1 -xf mainline.tar.xz -C /tmp/yuzu/mainline \
    && cp /tmp/patches/*.patch /tmp/yuzu/room/patches 2>/dev/null \
    && cd /tmp/yuzu/mainline \
    && git apply /tmp/yuzu/room/patches/*.patch \
    && bash /tmp/yuzu/room/.ci/deps.sh \
    && { echo "#!/bin/ash"; \
         echo "SCRIPT_DIR=\$(dirname \"\$(readlink -f \"\$0\")\")"; \
         echo "cd \$SCRIPT_DIR"; \
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

FROM alpine:3.20

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