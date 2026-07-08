# nixos-desktop-tmpl

A GitHub template for a Japanese-friendly NixOS desktop: [niri](https://github.com/YaLTeR/niri) (a
scrollable-tiling Wayland compositor) driven entirely by a single Nix flake, with reproducible
dotfiles managed through home-manager.

## Table of contents

- [What you get](#what-you-get)
- [Requirements](#requirements)
- [Install](#install)
- [Keyboard cheatsheet](#keyboard-cheatsheet)
- [Customization](#customization)
- [Day-2 operations](#day-2-operations)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## What you get

- **[niri](https://github.com/YaLTeR/niri)** as the only compositor — a scrollable-tiling Wayland
  window manager, with no GNOME/GDM stack involved.
- **[noctalia](https://noctalia.dev)** as the desktop shell (launcher, clipboard, control center,
  settings panel, screen lock) and **noctalia-greeter** as a matching graphical login screen on
  top of `greetd`.
- **fcitx5 + mozc** Japanese input, wired up with `waylandFrontend` and an `xremap`-based key
  scheme so you can toggle input mode without a dedicated IME key (see the
  [keyboard cheatsheet](#keyboard-cheatsheet)).
- A **Tokyo Night** color scheme applied consistently across niri, noctalia, the terminal, and the
  bundled wallpaper (`assets/wallpapers/tokyo-night.png`).
- A curated set of CLI tools (git, gh, ghq, ripgrep, fzf, fd, bat, delta, lazygit, neovim, tmux,
  starship, zoxide, yazi, just, jq, direnv, lsd) and Firefox + Chromium as browsers
  (`NIXOS_OZONE_WL` enabled for native Wayland).
- `en_US` UI locale with `LC_*` set to `ja_JP` and the timezone pinned to `Asia/Tokyo`.

## Requirements

- A machine that can boot the official NixOS installer ISO (x86_64-linux).
- A working internet connection during install (for fetching the flake and packages).
- Basic familiarity with a terminal — the installer is a single script, but you should be able to
  read its output and intervene if something looks wrong.

## Install

1. **Use this template.** Click "Use this template" on GitHub (or `gh repo create --template
   <this-repo>`) to create your own copy, e.g. `you/nixos-desktop-tmpl`.
2. **Install plain NixOS from USB.** Boot the official NixOS ISO, partition the disk, and get to a
   minimal working NixOS install with networking up (the standard graphical or manual installer —
   you do not need to configure a desktop environment at this stage).
3. **Run the installer against your repo:**

   ```sh
   curl -fsSL https://raw.githubusercontent.com/<you>/<repo>/main/install.sh | bash -s -- https://github.com/<you>/<repo>
   ```

`install.sh` then:

- Detects your username, hostname, NixOS `stateVersion`, and CPU vendor, and regenerates
  `vars.nix` with those values (this is the only file it rewrites).
- Runs `nixos-generate-config` and copies the resulting hardware configuration into
  `hosts/default/hardware-configuration.nix`, replacing the CI placeholder stub.
- Commits both changes under an "installer" identity, so the flake stays pure (no `--impure`,
  no untracked-file surprises).
- Runs `sudo nixos-rebuild switch --flake .#$hostname` to activate the system.

Reboot afterwards and you should land on the noctalia-greeter login screen with niri available as
a session.

## Keyboard cheatsheet

Modifier keys first — these come from the system-wide `xremap` config
(`modules/system/keyboard.nix`) and apply everywhere, not just inside niri:

| Key | Action |
|---|---|
| `CapsLock` | Remapped to `Ctrl` |
| Left `Alt`, tapped alone | Switch IME to 英数 (direct input / IME off) |
| Right `Alt`, tapped alone | Switch IME to かな (mozc / IME on) |
| Left `Alt` / Right `Alt`, held | Behaves as a normal modifier (`Alt`) |

niri window/workspace bindings (`dotfiles/niri/config.kdl`):

| Key | Action |
|---|---|
| `Alt+Shift+/` | Show the hotkey overlay (full in-compositor cheatsheet) |
| `Ctrl+Space` | Noctalia: Launcher |
| `Super+V` | Noctalia: Clipboard history |
| `Super+S` | Noctalia: Control Center |
| `Super+I` | Noctalia: Settings |
| `Super+L` | Noctalia: Lock screen |
| `Super+W` | Close focused window |
| `Alt+Left` / `Alt+H` | Focus column left |
| `Alt+Right` / `Alt+L` | Focus column right |
| `Alt+Up` / `Alt+K` | Focus window up |
| `Alt+Down` / `Alt+J` | Focus window down |
| `Alt+Shift+Left` / `Alt+Shift+H` | Move column left |
| `Alt+Shift+Right` / `Alt+Shift+L` | Move column right |
| `Alt+Shift+Up` / `Alt+Shift+K` | Move window up |
| `Alt+Shift+Down` / `Alt+Shift+J` | Move window down |
| `Alt+1` .. `Alt+4` | Focus workspace 1-4 |
| `Alt+Shift+1` .. `Alt+Shift+4` | Move column to workspace 1-4 |
| `Alt+R` | Switch preset column width |
| `Alt+C` | Center column |
| `Alt+F` | Maximize column |
| `Alt+Shift+F` | Fullscreen window |
| `Alt+Minus` / `Alt+Equal` | Shrink / grow column width by 10% |
| `Alt+Comma` / `Alt+Period` | Consume window into column / expel from column |
| `Print` | Screenshot (interactive) |
| `Ctrl+Print` | Screenshot the whole screen |
| `Alt+Print` | Screenshot the focused window |
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` | Volume up / down (via `wpctl`) |
| `XF86AudioMute` | Toggle mute |
| `Alt+Shift+E` | Quit niri |
| `Alt+Shift+P` | Power off monitors |

## Customization

### `vars.nix`

The only file `install.sh` rewrites. Everything else is meant to be edited by you and committed
normally.

| Key | Meaning |
|---|---|
| `username` | Your Linux user, used across `modules/system/core.nix` and home-manager |
| `hostname` | Selects the `nixosConfigurations.<hostname>` you rebuild with `just switch` |
| `stateVersion` | Pinned NixOS/home-manager state version; detected once at install time, do not change afterwards |
| `cpuVendor` | `"intel"`, `"amd"`, or `"other"` — selects the matching `nixos-hardware` CPU module |

### `modules/` and `dotfiles/`

| Module | Backs | Delivery |
|---|---|---|
| `modules/system/core.nix` | boot, networking, locale, timezone, user account | driven by `vars.nix`, no dotfiles |
| `modules/system/desktop.nix` | greetd + noctalia-greeter, niri, PipeWire, browsers | no dotfiles directly |
| `modules/system/fonts.nix` | Noto CJK, emoji, HackGen Nerd Font | no dotfiles |
| `modules/system/keyboard.nix` | system-wide `xremap` (CapsLock/Alt scheme) | no dotfiles |
| `modules/home/niri.nix` | niri compositor config | `dotfiles/niri/config.kdl` (read-only symlink) |
| `modules/home/fcitx5.nix` | IME config, mozc | `dotfiles/fcitx5/{config,conf/mozc.conf,profile}` (**seeded**, mutable) |
| `modules/home/noctalia.nix` | desktop shell settings, wallpaper | `dotfiles/noctalia/settings.toml` (**seeded**, mutable) + `assets/wallpapers/tokyo-night.png` |
| `modules/home/ghostty.nix` | terminal emulator config | `dotfiles/ghostty/config` (read-only symlink) |
| `modules/home/shell.nix` | zsh, tmux, starship | `dotfiles/{zsh/*,tmux/*,starship.toml}` (read-only symlink) |
| `modules/home/git.nix` | git, gh credential helper, ghq root | `dotfiles/lazygit/config.yml` (read-only symlink) |
| `modules/home/cli.nix` | CLI package set | no dotfiles |

**Seed strategy for fcitx5 and noctalia:** these two apps write their own config back to disk at
runtime (fcitx5-configtool, the noctalia GUI), so home-manager cannot manage them as read-only
symlinks. Instead, the file is copied into place only if it doesn't already exist ("seeded") on
the first `home-manager` activation. After that, whatever the GUI writes wins — home-manager will
not overwrite it on subsequent `just switch` runs. To reset either app to the template defaults,
delete the live file (e.g. `~/.local/state/noctalia/settings.toml` or the fcitx5 config directory)
and run `just switch` again to reseed it.

## Day-2 operations

```sh
just switch   # nixos-rebuild switch --flake .#$(hostname)
just check    # nix flake check --no-build (same check CI runs)
just fmt      # nix fmt (nixfmt-rfc-style)
just update   # nix flake update
```

A scheduled `update-flake-lock.yml` workflow also opens a PR against `flake.lock` twice a week;
merging it and running `just switch` is the usual way to pick up upstream updates.

> [!IMPORTANT]
> For that workflow to open PRs with the default `GITHUB_TOKEN`, your repository must allow it:
> **Settings → Actions → General → Workflow permissions → check "Allow GitHub Actions to create
> and approve pull requests"**. This is a per-repository setting, so repos generated from this
> template start with it disabled and the scheduled run fails at the "create pull request" step
> until you flip it. Alternatively, store a fine-grained PAT as the `FLAKE_UPDATE_TOKEN` secret —
> PRs opened with a PAT also trigger the CI workflow automatically.

## Troubleshooting

- **Black screen after boot.** Double-check `vars.nix`'s `cpuVendor` matches your actual CPU
  (`"intel"` / `"amd"` / `"other"`) — this selects microcode and, on Intel, whether the
  `i915` module is forced early in `initrd`. Also confirm your GPU is actually supported by the
  in-tree driver niri/wlroots picks up (`mesa` covers the common Intel/AMD cases out of the box).
- **noctalia-greeter doesn't come up / stays blank.** It's a young project (a single upstream
  release tag as of this writing) and can fail to initialize the GPU on some hardware. Switch to a
  text VT with `Ctrl+Alt+F2`, log in there, and inspect `journalctl -u greetd` for the real error.
  See the upstream troubleshooting guide at
  [docs.noctalia.dev/v5/greeter](https://docs.noctalia.dev/v5/greeter/) for known issues and
  fixes. As a last resort, `modules/system/desktop.nix` has a comment marking where to swap the
  greeter for `tuigreet` while you debug.
- **`hosts/default/hardware-configuration.nix` is still the placeholder stub.** This ships in the
  template as a stub with a warning header so `nix flake check` can eval on any machine. Do **not**
  run `just switch` before `install.sh` has replaced it with your real hardware config — it does
  not describe your actual disks/filesystems and rebuilding with it can leave the system unbootable.

## License

MIT — see [LICENSE](LICENSE).
