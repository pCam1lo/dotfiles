#!/usr/bin/env bash
#
# One-line bootstrap for the i3 dotfiles fork.
# Clones the repository into a temporary directory, runs install.sh, and
# removes the temporary clone afterwards. User files are managed by install.sh.
#
set -euo pipefail

REPO_URL="https://github.com/pCam1lo/dotfiles.git"
BRANCH="v4"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
    if command -v pacman >/dev/null 2>&1; then
        echo "git is missing; installing it with pacman..."
        sudo pacman -S --needed git
    else
        echo "git is required. Install it and run this script again." >&2
        exit 1
    fi
fi

echo "Cloning $REPO_URL ($BRANCH)..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/repo"

chmod +x "$TMP_DIR/repo/install.sh"

"$TMP_DIR/repo/install.sh" "$@"
