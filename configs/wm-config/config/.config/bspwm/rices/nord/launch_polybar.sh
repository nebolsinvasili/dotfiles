#!/usr/bin/env sh

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar -c ./config.ini left &
polybar -c ./config.ini xwindow &
polybar -c ./config.ini center &
polybar -c ./config.ini tray &
polybar -c ./config.ini right &
polybar -c ./config.ini poweroff &
