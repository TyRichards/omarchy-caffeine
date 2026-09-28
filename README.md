# Omarchy Caffeine

A one-click **always on** mode for Omarchy laptops. When the bolt in the bar is
lit, closing the lid does nothing: no suspend, no idle screensaver, no idle
lock. Agents, music, servers, downloads, everything keeps running exactly as if
the lid were open.

## How it works

`bin/omarchy-caffeine on` starts a user-level
`systemd-inhibit --mode=block` holding these inhibitors:

| Inhibitor              | Effect                                           |
|------------------------|--------------------------------------------------|
| `handle-lid-switch`    | logind ignores the lid; no suspend on close      |
| `sleep`                | blocks any other suspend/hibernate request       |
| `idle`                 | logind never reports the session idle            |
| `handle-suspend-key`   | the suspend key is ignored                       |
| `handle-hibernate-key` | the hibernate key is ignored                     |

It also turns on Omarchy's built-in *Stay Awake* (no screensaver or idle lock)
and turns it back off when Caffeine is turned off, unless you had it on already.

No root is needed. The inhibitor runs detached, so it survives a shell restart.
It does not survive a reboot; always-on is off after boot.

## Install

```bash
git clone https://github.com/TyRichards/omarchy-caffeine ~/Work/github.com/TyRichards/omarchy-caffeine
~/Work/github.com/TyRichards/omarchy-caffeine/install.sh
```

## Use

- **Left click** the bolt: toggle always on.
- **Right click**: list current inhibitors in a terminal.
- CLI: `bin/omarchy-caffeine on|off|toggle|status`
- IPC: `omarchy-shell io.github.tyrichards.caffeine toggle`

Bind a key in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + C", "Toggle always on", "omarchy-shell io.github.tyrichards.caffeine toggle")
```

## Notes

- Closing the lid with no external monitor still locks the screen (Omarchy's
  default). Processes are not affected by the lock.
- Battery drains at the normal running rate while the lid is closed. Plug in.
- Check what is holding the machine awake: `systemd-inhibit --list`.
