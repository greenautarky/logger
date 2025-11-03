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

set -e
echo    "Starting Fluent Bit"
/usr/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf

echo "Starting Telegraf"
exec telegraf --config /etc/telegraf/telegraf.conf

