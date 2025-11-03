#!/usr/bin/env bashio
# ==============================================================================
# Home Assistant Community Add-on: Log
# Run the Loggers: FluentBit and Telegraf
# ==============================================================================
#
# WHAT IS THIS FILE?!
#
# The Log add-on runs in the host PID namespace, therefore it cannot
# use the regular S6-Overlay; hence this add-on uses a "old school" script
# to run; with a couple of "hacks" to make it work.
# ==============================================================================
/etc/cont-init.d/banner.sh

#!/usr/bin/env sh
set -eu

FB_CONF="${FB_CONF:-/etc/fluent-bit/fluent-bit.conf}"
TG_CONF="${TG_CONF:-/etc/telegraf/telegraf.conf}"

# start both in background
/usr/bin/fluent-bit -c "$FB_CONF" ${FB_ARGS:-} &
FB_PID=$!
telegraf --config "$TG_CONF" ${TG_ARGS:-} &
TG_PID=$!

# stop both cleanly on Ctrl+C/stop
trap 'kill -TERM $FB_PID $TG_PID 2>/dev/null' INT TERM HUP

# simple “stay alive” loop; exit if either dies
while kill -0 "$FB_PID" 2>/dev/null && kill -0 "$TG_PID" 2>/dev/null; do
  sleep 1
done

# propagate a useful exit code
wait "$FB_PID" 2>/dev/null || FB_STATUS=$? || FB_STATUS=0
wait "$TG_PID" 2>/dev/null || TG_STATUS=$? || TG_STATUS=0
exit ${FB_STATUS:-0}${TG_STATUS:+$TG_STATUS}
