#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
   "$@" &
  fi
}

run kbdd
run emacs --daemon
run nm-applet
run xautolock -resetsaver -detectsleep -time 5 -locker "/home/nemoi/.local/bin/lockscreen off" -nowlocker "/home/nemoi/.local/bin/lockscreen"
