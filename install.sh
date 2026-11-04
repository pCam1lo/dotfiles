#!/usr/bin/env bash
#
# Keyitdev-style i3 dotfiles - safe Arch/EndeavourOS installer.
#
# This script installs user configuration only. It never runs a full system
# upgrade, never changes the display manager, and never touches ~/.config/xfce4.
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
BACKUP_DIR="$DATA_HOME/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
INSTALL_PACKAGES=1
WITH_GTK=0
WITH_XINITRC=0

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run          Show what would be done, without changing anything.
  --no-packages      Do not install packages; only copy configuration files.
  --with-gtk         Also install the GTK settings.ini (affects all GTK apps,
                     including XFCE; a backup is created first).
  --with-xinitrc     Install ~/.xinitrc (only useful if you start X with startx).
  -h, --help         Show this help.

The installer copies files only into your home directory. It never runs
"pacman -Syu", never enables/changes SDDM or LightDM, and never replaces
~/.config/xfce4.
EOF
}

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '  [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

backup_path() {
    local dest="$1"
    local rel="${dest#"$HOME"/}"

    if [ "$rel" = "$dest" ]; then
        warn "refusing to back up a path outside \$HOME: $dest"
        return 1
    fi

    if [ -e "$dest" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$dest" "$BACKUP_DIR/$rel"
        printf '  backed up: %s\n' "$dest"
    fi
}

copy_path() {
    local src="$1"
    local dest="$2"

    [ -e "$src" ] || { warn "missing source: $src"; return 0; }

    if [ "$DRY_RUN" -eq 1 ]; then
        printf '  [dry-run] copy %s -> %s\n' "$src" "$dest"
        return 0
    fi

    if [ -e "$dest" ]; then
        backup_path "$dest"
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    printf '  installed: %s\n' "$dest"
}

install_packages() {
    local packages=(
        i3-wm i3status polybar picom dunst feh xss-lock rofi alacritty
        dmenu xclip maim slop dex libnotify jq xorg-xrandr xorg-xdpyinfo
        xorg-xinput brightnessctl playerctl upower network-manager-applet
        polkit-gnome networkmanager-dmenu papirus-icon-theme
        ttf-roboto-mono ttf-opensans ttf-jetbrains-mono-nerd
    )
    local missing=()
    local package

    for package in "${packages[@]}"; do
        if ! pacman -Q "$package" >/dev/null 2>&1; then
            missing+=("$package")
        fi
    done

    if [ "${#missing[@]}" -eq 0 ]; then
        log "All required packages are already installed."
        return 0
    fi

    log "Installing missing packages (no system upgrade):"
    printf '  %s\n' "${missing[*]}"
    run sudo pacman -S --needed "${missing[@]}"

    if ! pacman -Q i3lock-color >/dev/null 2>&1; then
        warn "i3lock-color is optional and lives in the AUR."
        warn "Without it, ~/.local/bin/lock falls back to vanilla i3lock."
    fi
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            --no-packages) INSTALL_PACKAGES=0 ;;
            --with-gtk) WITH_GTK=1 ;;
            --with-xinitrc) WITH_XINITRC=1 ;;
            -h|--help) usage; exit 0 ;;
            *) die "unknown option: $1 (use --help)" ;;
        esac
        shift
    done

    [ "$(id -u)" -ne 0 ] || die "Run this installer as your normal user, not as root."
    command -v pacman >/dev/null 2>&1 || die "This installer supports Arch-based systems only."

    log "Repository: $REPO_DIR"
    log "Backups:    $BACKUP_DIR"

    if [ "$INSTALL_PACKAGES" -eq 1 ]; then
        install_packages
    else
        warn "Skipping package installation (--no-packages)."
    fi

    log "Installing i3, Polybar, Picom, Rofi and Dunst configuration."
    copy_path "$REPO_DIR/home/.config/i3" "$CONFIG_HOME/i3"
    copy_path "$REPO_DIR/home/.config/polybar" "$CONFIG_HOME/polybar"
    copy_path "$REPO_DIR/home/.config/picom" "$CONFIG_HOME/picom"
    copy_path "$REPO_DIR/home/.config/rofi" "$CONFIG_HOME/rofi"
    copy_path "$REPO_DIR/home/.config/dunst" "$CONFIG_HOME/dunst"
    copy_path "$REPO_DIR/home/.config/alacritty" "$CONFIG_HOME/alacritty"

    log "Installing helper scripts into ~/.local/bin."
    [ "$DRY_RUN" -eq 1 ] || mkdir -p "$HOME/.local/bin"
    for script in "$REPO_DIR"/usr/local/bin/*; do
        [ -f "$script" ] || continue
        [ "$(basename "$script")" = "icons" ] && continue
        copy_path "$script" "$HOME/.local/bin/$(basename "$script")"
    done
    copy_path "$REPO_DIR/usr/local/bin/icons" "$DATA_HOME/keyitdev/icons"
    run chmod +x "$HOME"/.local/bin/* 2>/dev/null || true

    log "Installing wallpaper, font and GTK theme."
    copy_path "$REPO_DIR/home/Pictures/wallpapers/background.png" \
              "$HOME/Pictures/wallpapers/background.png"
    [ "$DRY_RUN" -eq 1 ] || mkdir -p "$DATA_HOME/fonts"
    copy_path "$REPO_DIR/usr/share/fonts/Feather.ttf" "$DATA_HOME/fonts/Feather.ttf"
    copy_path "$REPO_DIR/usr/share/themes/gtk-dark-keyitdev" \
              "$HOME/.themes/gtk-dark-keyitdev"

    if [ "$WITH_GTK" -eq 1 ]; then
        warn "Installing GTK settings.ini. This affects XFCE and other GTK apps too."
        copy_path "$REPO_DIR/home/.config/gtk-3.0/settings.ini" "$CONFIG_HOME/gtk-3.0/settings.ini"
        copy_path "$REPO_DIR/home/.config/gtk-4.0/settings.ini" "$CONFIG_HOME/gtk-4.0/settings.ini"
    else
        log "Leaving GTK settings untouched (use --with-gtk if you want the theme settings)."
    fi

    if [ "$WITH_XINITRC" -eq 1 ]; then
        copy_path "$REPO_DIR/home/.xinitrc" "$HOME/.xinitrc"
    fi

    if [ "$DRY_RUN" -eq 0 ]; then
        fc-cache -f "$DATA_HOME/fonts" >/dev/null 2>&1 || true
    fi

    cat <<EOF

Done.

Next steps:
  1. Log out of XFCE.
  2. At the SDDM login screen, choose the "i3" session.
  3. If Polybar or Picom do not start, run: i3-msg restart
  4. Read the keybindings and hardware notes in README.md.

Restore a previous file from the backup with:
  cp -a "$BACKUP_DIR/<relative-path>" "\$HOME/<relative-path>"
EOF
}

main "$@"
