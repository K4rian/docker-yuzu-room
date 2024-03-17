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
fi

print_header() {
  local pf="● %-19s %-25s\n"

  [ ! "x$YUZU_ROOMDESC" = "x" ] && room_desc="${YUZU_ROOMDESC}" || room_desc="(unset)"
  [ ! "x$s_password" = "x" ] && room_pass="Yes" || room_pass="No"
  [ $YUZU_ISPUBLIC = 1 ] && room_public="Yes" || room_public="No"
  [ ! "x$YUZU_PREFGAMEID" = "x" ] && room_pgid="${YUZU_PREFGAMEID}" || room_pgid="(unset)"
  [ ! "x$YUZU_WEBAPIURL" = "x" ] && room_api="${YUZU_WEBAPIURL}" || room_api="(unset)"

  printf "\n"
  printf "░█░█░█░█░▀▀█░█░█░░░█▀▄░█▀▀░█▀▄░▀█▀░█▀▀░█▀█░▀█▀░█▀▀░█▀▄░░░█▀▄░█▀█░█▀█░█▄█\n"
  printf "░░█░░█░█░▄▀░░█░█░░░█░█░█▀▀░█░█░░█░░█░░░█▀█░░█░░█▀▀░█░█░░░█▀▄░█░█░█░█░█░█\n"
  printf "░░▀░░▀▀▀░▀▀▀░▀▀▀░░░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀░░░░▀░▀░▀▀▀░▀▀▀░▀░▀\n"
  printf "\n"
  printf "$pf" "Host:" "${YUZU_BINDADDR}"
  printf "$pf" "Port:" "${YUZU_PORT}"
  printf "$pf" "Name:" "${YUZU_ROOMNAME}"
  printf "$pf" "Description:" "${room_desc}"
  printf "$pf" "Password:" "${room_pass}"
  printf "$pf" "Public:" "${room_public}"
  printf "$pf" "Preferred Game:" "${YUZU_PREFGAME}"
  printf "$pf" "Preferred Game ID:" "${room_pgid}"
  printf "$pf" "Maximum Members:" "${YUZU_MAXMEMBERS}"
  printf "$pf" "Banlist File:" "${YUZU_BANLISTFILE}"
  printf "$pf" "Log File:" "${YUZU_LOGFILE}"
  printf "$pf" "Web API URL:" "${room_api}"
  printf "\n"
}

print_header
eval "$s_command"