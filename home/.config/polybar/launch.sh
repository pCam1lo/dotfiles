#!/bin/sh
# Launch one Polybar instance per connected monitor.
# A lock prevents two display events from starting duplicate bars.

set -eu

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config.ini"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/polybar-launch.lock"

# Serialize launches. If another launch is in progress, let it finish.
exec 9>"$LOCK"
flock -n 9 || exit 0

# Stop previous instances quietly.
polybar-msg cmd quit >/dev/null 2>&1 || true
pkill -u "$UID" -x polybar 2>/dev/null || true

# Wait until the old instances are gone.
while pgrep -u "$UID" -x polybar >/dev/null 2>&1; do
    sleep 0.1
done

monitors="$(polybar -m 2>/dev/null | cut -d: -f1)"

if [ -z "$monitors" ]; then
    MONITOR= polybar main --config="$CONFIG" >/tmp/polybar.log 2>&1 &
else
    for monitor in $monitors; do
        MONITOR="$monitor" polybar main --config="$CONFIG" >/tmp/polybar-"$monitor".log 2>&1 &
    done
fi

echo "Polybar launched."
