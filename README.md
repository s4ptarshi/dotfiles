# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- `git`
- `stow`
- `fish` (shell)
- `nvim` (editor)
- `kitty` / `ghostty` (terminal)
- `tmux`
- `hyprland` / `niri` (Wayland compositor)

## Installation

```bash
git clone --recurse-submodules git@github.com:s4ptarshi/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Stow individual directories as needed:

```bash
stow fish
stow kitty
stow ghostty
stow nvim
stow tmux
stow scripts
stow dms_hypr
stow uwsm
stow rclone
stow darktable
```

The `.stowrc` file sets `--target=$HOME`, so running `stow <name>` from the repo root will symlink into your home directory automatically.

## Directory Overview

| Directory | Contents |
|---|---|
| `fish/` | Fish shell config, hydro prompt, abbreviations, vi mode, lazy conda loader |
| `kitty/` | Kitty terminal config (performance tuning, tiling layouts, remote control) |
| `ghostty/` | Ghostty terminal config (transparency, blur, keybindings) |
| `nvim/` | Neovim config based on [LazyVim](https://www.lazyvim.org/) with custom plugins |
| `tmux/` | Tmux config with vi-mode keys, tokyo-night theme, continuum/resurrect plugins |
| `dms_hypr/` | Hyprland + Niri config with [Dank Material Shell](https://github.com/s4ptarshi/Dank-Material-Shell), matugen color generation |
| `end4_hyprland/` | Alternative Hyprland config (end-4 dots style) |
| `scripts/` | Custom scripts (`mp3con`, rclone sync helpers, KDE theme updater, PATH setup) |
| `rclone/` | Rclone filter rules and systemd/cron management scripts |
| `darktable/` | Darktable themes and shortcuts |
| `asus_g14/` | ASUS G14 laptop configs (udev key remapping, Anime Matrix LED, ROG control) |
| `uwsm/` | Universal Wayland Session Manager environment variables |

## Machine-Specific Setup

Some files are intentionally gitignored and need to be created per machine:

```bash
# Fish secrets (API keys, etc.)
cp fish/.config/fish/vars.fish.example fish/.config/fish/vars.fish
$EDITOR fish/.config/fish/vars.fish

# DMS auto-generates these on first run:
#   dms_hypr/.config/hypr/dms/outputs.conf
#   dms_hypr/.config/hypr/dms/colors.conf
#   dms_hypr/.config/niri/dms/colors.kdl
#   ghostty/.config/ghostty/themes/dankcolors
#   kitty/.config/kitty/dank-tabs.conf
#   kitty/.config/kitty/dank-theme.conf
```

## Post-Install

After stowing, run these to finish setup:

```bash
# Fish plugins (via fisher)
fisher update

# Tmux plugins (prefix + I inside tmux)
tmux source ~/.config/tmux/tmux.conf

# Neovim (LazyVim bootstraps on first launch)
nvim
```

Generate DMS color schemes if needed:

```bash
matugen image ~/path/to/wallpaper.png
```

## Submodules

| Submodule | Purpose |
|---|---|
| `tmux/.config/tmux/plugins/tpm` | Tmux Plugin Manager |
| `tmux/.config/tmux/plugins/tmux-continuum` | Continuous tmux saving |
| `tmux/.config/tmux/plugins/tmux-resurrect` | Tmux session restore |
| `tmux/.config/tmux/plugins/tokyo-night-tmux` | Tokyo Night theme |
| `dms_hypr/.config/hypr/hyprsplit` | Hyprland workspace splitting |
