#!/bin/sh
# Launch one Polybar instance per connected monitor.
# Polybar reads $MONITOR when the [bar] monitor option is empty.

set -eu

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config.ini"

# Stop previous instances quietly.
polybar-msg cmd quit >/dev/null 2>&1 || true
pkill -x polybar 2>/dev/null || true

monitors="$(polybar -m 2>/dev/null | cut -d: -f1)"
[ -n "$monitors" ] || monitors=""

if [ -z "$monitors" ]; then
    MONITOR= polybar main --config="$CONFIG" >/tmp/polybar.log 2>&1 &
else
    for monitor in $monitors; do
        MONITOR="$monitor" polybar main --config="$CONFIG" >/tmp/polybar-"$monitor".log 2>&1 &
    done
fi

echo "Polybar launched."
