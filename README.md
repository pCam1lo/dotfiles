# i3 dotfiles for Arch Linux

A small, keyboard-driven i3 setup with Polybar, Picom, Rofi and Dunst.
It is based on [Keyitdev/dotfiles](https://github.com/Keyitdev/dotfiles) and
adapted for a 1366x768 laptop with an `ACAD`/`BAT1` power supply, `LVDS1`
internal display and `wlan0` Wi-Fi.

The installer is intentionally conservative: it writes only user
configuration into `$HOME`, creates backups, and never changes the display
manager or runs a full system upgrade.

## Requirements

- Arch Linux or an Arch-based distribution (EndeavourOS, CachyOS, etc.).
- `pacman` and `sudo`.
- An X11 session. The configuration uses Picom and X11-only tools.
- A display manager is optional. SDDM/LightDM are not modified by the
  installer; existing i3 session entries are provided by the `i3-wm` package.

## Installation

Update your system first, manually:

```sh
sudo pacman -Syu
```

Then clone and install:

```sh
git clone https://github.com/pCam1lo/dotfiles.git
cd dotfiles
./install.sh --dry-run     # review the actions
./install.sh               # install
```

Log out and choose the **i3** session at the login screen.

Useful options:

```sh
./install.sh --no-packages # only copy files
./install.sh --with-gtk    # also install GTK settings.ini (affects XFCE too)
./install.sh --with-xinitrc
```

The installer does **not** run `pacman -Syu`, does **not** enable SDDM or
LightDM, and does **not** replace `~/.config/xfce4`.

## Repository structure

```text
.
├── install.sh                  # safe Arch installer
├── home/
│   ├── .config/
│   │   ├── i3/config           # window manager
│   │   ├── alacritty/          # terminal colors
│   │   ├── polybar/            # top bar, colors and launcher
│   │   ├── picom/picom.conf    # compositor, inactive-window opacity
│   │   ├── rofi/               # launcher, power menu and screenshot menu
│   │   └── dunst/dunstrc       # notifications
│   ├── Pictures/wallpapers/    # default wallpaper
│   └── .xinitrc                # optional startx entry
└── usr/
    ├── local/bin/              # helper scripts installed to ~/.local/bin
    │   ├── icons/              # notification icons
    │   ├── battery_listener
    │   ├── brightness_control
    │   ├── brightness_level
    │   ├── display-toggle
    │   ├── lock
    │   ├── microphone_mute
    │   ├── rofi-powermenu
    │   ├── rofi-screenshot
    │   ├── screenshot
    │   ├── touchpad_toggle
    │   ├── volume_control
    │   ├── volume_level
    │   └── volume_mute
    ├── share/fonts/Feather.ttf
    └── share/themes/gtk-dark-keyitdev/
```

The `usr/` tree is a source tree, not a request to write to `/usr`. The
installer copies scripts to `~/.local/bin`, fonts to
`~/.local/share/fonts`, and the GTK theme to `~/.themes`.

## Packages

The installer installs only the missing packages with
`sudo pacman -S --needed`. It does not upgrade the system.

| Package | Purpose |
|---|---|
| `i3-wm`, `i3status` | Window manager and optional status command |
| `polybar` | Top bar |
| `picom` | Compositor, fading and inactive-window opacity |
| `dunst` | Notification daemon |
| `feh` | Wallpaper setter |
| `xss-lock` | Locks the screen before suspend |
| `rofi` | Application launcher, power menu and screenshot menu |
| `alacritty` | Terminal used by `Super+Enter` |
| `dmenu` | Fallback launcher on `Ctrl+F3` |
| `xclip` | Copies screenshots to the clipboard |
| `maim`, `slop` | Screenshot selection |
| `dex` | Runs XDG autostart entries |
| `libnotify` | `notify-send` notifications |
| `xorg-xrandr`, `xorg-xdpyinfo` | Display and X11 information |
| `xorg-xinput` | Touchpad toggle |
| `brightnessctl` | Brightness control without root |
| `playerctl` | Media keys |
| `upower` | Battery listener |
| `network-manager-applet` | Network tray applet |
| `polkit-gnome` | Polkit authentication agent |
| `networkmanager-dmenu` | Network menu from Polybar |
| `papirus-icon-theme` | Rofi icons |
| `ttf-roboto-mono` | Rofi and Dunst font |
| `ttf-opensans` | i3 and lock-screen font |
| `ttf-jetbrains-mono-nerd` | Polybar and Rofi Nerd Font |

Optional:

| Package | Purpose |
|---|---|
| `i3lock-color` (AUR) | Fancy lock screen; the `lock` script falls back to plain `i3lock` |
| `mpd`, `ncmpcpp` | Music client; the `Super+Z` binding is commented out until installed |
| `brave-bin` (AUR) | Browser; no browser is installed by default and Firefox is not used |

## Keybindings

`$mod` is the **Super** key.

| Key | Action |
|---|---|
| `Super+Enter` | Open Alacritty |
| `Super+Q` | Close the focused window |
| `Super+Shift+Q` | Close the focused window (alternate) |
| `Super+D` | Rofi application launcher |
| `Super+A` | Rofi launcher with the top bar style |
| `Super+E` | Thunar |
| `Super+S` | Screenshots folder in Thunar |
| `Super+X` | Power menu |
| `Super+C` | Screenshot menu |
| `Super+I` | Lock screen |
| `Super+B` | Move workspace to the output on the right |
| `Super+N` | Internal panel + first connected external output |
| `Super+M` | Internal panel only |
| `Super+J/K/L/;` | Focus left/down/up/right |
| `Super+Shift+J/K/L/;` | Move window left/down/up/right |
| `Super+1..0` | Switch workspace |
| `Super+Shift+1..0` | Move window to workspace |
| `Super+R` | Resize mode |
| `Super+G` | Gap adjustment mode |
| `Super+Shift+C` | Reload i3 |
| `Super+Shift+R` | Restart i3 |
| `Super+Shift+E` | Exit i3 |
| `Ctrl+F1/F2` | Alacritty |
| `Ctrl+F3` | `dmenu_run` |
| `Ctrl+F4` | Stop Picom |

## Hardware notes

This fork was adapted for the following devices. Change them if your machine
uses different names:

| Item | Value | Where |
|---|---|---|
| Battery | `BAT1` | `~/.config/polybar/config.ini` |
| AC adapter | `ACAD` | `~/.config/polybar/config.ini` |
| Internal display | `LVDS1` | `~/.local/bin/display-toggle` |
| External outputs | `DP1`, `HDMI1`, `VGA1` | `~/.local/bin/display-toggle` |
| CPU temperature | `/sys/class/hwmon/hwmon3/temp1_input` | `~/.config/polybar/config.ini` |
| Wi-Fi interface | `wlan0` | `~/.config/polybar/config.ini` |
| Backlight | `intel_backlight` | `~/.config/polybar/config.ini` |

Check your own values with:

```sh
ls /sys/class/power_supply/
ls /sys/class/backlight/
for d in /sys/class/hwmon/hwmon*; do echo "$d: $(cat "$d/name")"; done
xrandr --query | grep connected
ip -br link
```

If the internal output is `eDP-1` instead of `LVDS1`, run:

```sh
INTERNAL=eDP-1 ~/.local/bin/display-toggle dual
```

## Picom and inactive windows

`~/.config/picom/picom.conf` includes:

```ini
inactive-opacity = 0.90;
active-opacity = 1.0;
```

Change `inactive-opacity` to taste. Picom is started with an explicit config
path so it does not depend on the current working directory.

## Backups and uninstall

Every replaced path is copied to:

```text
~/.local/share/dotfiles-backup/YYYYMMDD-HHMMSS/
```

Restore one file with:

```sh
cp -a ~/.local/share/dotfiles-backup/<timestamp>/.config/i3/config \
      ~/.config/i3/config
```

To remove the setup, delete the installed user files:

```sh
rm -rf ~/.config/i3 ~/.config/polybar ~/.config/picom ~/.config/rofi ~/.config/dunst
rm -rf ~/.local/bin/{battery_listener,brightness_control,brightness_level,display-toggle,lock,microphone_mute,rofi-powermenu,rofi-screenshot,screenshot,touchpad_toggle,volume_control,volume_level,volume_mute}
rm -rf ~/.local/share/keyitdev
rm -rf ~/.themes/gtk-dark-keyitdev
```

Then choose XFCE again at the login screen.

## Notes

- XFCE configuration is not modified. The GTK theme is installed but not
  activated unless you run `install.sh --with-gtk`.
- The ASUS fan scripts are copied but not started; they are specific to ASUS
  laptops.
- `Super+Q` closes windows. Firefox is not installed or bound.
- Brave is not installed by default. If you install `brave-bin`, use
  `brave` as the command in your own bindings.

## Credits

Based on [Keyitdev/dotfiles](https://github.com/Keyitdev/dotfiles), with
adaptations for this laptop. See the original repository and its contributors
for the original design.
