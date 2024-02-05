# keyjump.yazi

A Yazi plugin which like flash.nvim in Neovim, allow use key char to precise selection.

## Keep mode

keep mode, when select a dir, it will auto enter and keep in "keyjump" mode.

When select a file or press <ESC> or select no match, it will leave "keyjump" mode.

https://github.com/DreamMaoMao/keyjump.yazi/assets/30348075/dd998a34-49b0-481d-b032-d9849a89ba48

## Normal mode

Normal mode, when select a item, it will auto leave keyjump mode

https://github.com/DreamMaoMao/keyjump/assets/30348075/6ba722ce-8b55-4c80-ac81-b6b7ade74491

## Install

### Linux

```bash
git clone https://github.com/DreamMaoMao/keyjump.yazi.git ~/.config/yazi/plugins/keyjump.yazi
```

### Windows

With `Powershell` :

```powershell
if (!(Test-Path $env:APPDATA\yazi\config\plugins\)) {mkdir $env:APPDATA\yazi\config\plugins\}
git clone https://github.com/DreamMaoMao/keyjump.yazi.git $env:APPDATA\yazi\config\plugins\keyjump.yazi
```

## Usage

set shortcut key to toggle keyjump mode in `~/.config/yazi/keymap.toml`. for example set `i` to toggle keyjump mode

```toml
[[manager.prepend_keymap]]
on   = [ "i" ]
exec = "plugin keyjump --sync --args=keep"
desc = "Keyjump (Keep mode)"
```

```toml
[[manager.prepend_keymap]]
on   = [ "i" ]
exec = "plugin keyjump --sync"
desc = "Keyjump (Normal mode)"
```

When you see some character(singal character or double character) in left of the entry.
Press the key of the character will jump to the corresponding entry
