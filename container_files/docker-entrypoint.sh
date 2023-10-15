#!/bin/ash
# yuzu Multiplayer Dedicated Lobby Startup Script
#
# Server Files: /home/yuzu

export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

clear

s_command="
$HOME/yuzu-room \
--bind-address \"${YUZU_BINDADDR}\" \
--port ${YUZU_PORT} \
--room-name \"${YUZU_ROOMNAME}\" \
--preferred-game \"${YUZU_PREFGAME}\" \
--max_members ${YUZU_MAXMEMBERS} \
--ban-list-file \"$YUZU_BANLISTFILE\" \
--log-file \"${YUZU_LOGFILE}\""
s_password="${YUZU_PASSWORD}"

add_optional_arg() {
  while [[ "$#" -gt 0 ]]; do
    s_command="$s_command $1"
    shift
  done
}

if [ ! "x$YUZU_ROOMDESC" = "x" ]; then
  add_optional_arg "--room-description" "\"$YUZU_ROOMDESC\""
fi

if [ ! "x$YUZU_PREFGAMEID" = "x" ]; then
  add_optional_arg "--preferred-game-id" "\"$YUZU_PREFGAMEID\""
fi

if [ "x$s_password" = "x" ] \
  && [ -f "/run/secrets/yuzuroom" ]; then
  s_password=$(cat "/run/secrets/yuzuroom")
fi

if [ ! "x$s_password" = "x" ]; then
  add_optional_arg "--password" "\"${s_password}\""
fi

if [ ! "x$YUZU_ISPUBLIC" = "x" ] \
 && [ $YUZU_ISPUBLIC = 1 ]; then
  if [ ! "x$YUZU_TOKEN" = "x" ]; then
    add_optional_arg "--token" "\"$YUZU_TOKEN\""
  fi

  if [ ! "x$YUZU_WEBAPIURL" = "x" ]; then
    add_optional_arg "--web-api-url" "\"$YUZU_WEBAPIURL\""
  fi

  if [ ! "x$YUZU_ENABLEMODS" = "x" ] \
   && [ $YUZU_ENABLEMODS = 1 ]; then
    add_optional_arg "--enable-yuzu-mods"
  fi
fi

echo "░█░█░█░█░▀▀█░█░█░░░█▀▄░█▀▀░█▀▄░▀█▀░█▀▀░█▀█░▀█▀░█▀▀░█▀▄░░░█▀▄░█▀█░█▀█░█▄█"
echo "░░█░░█░█░▄▀░░█░█░░░█░█░█▀▀░█░█░░█░░█░░░█▀█░░█░░█▀▀░█░█░░░█▀▄░█░█░█░█░█░█"
echo "░░▀░░▀▀▀░▀▀▀░▀▀▀░░░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀░░░░▀░▀░▀▀▀░▀▀▀░▀░▀"

eval "$s_command"
