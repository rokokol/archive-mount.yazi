# archive-mount.yazi

[![workarounds](https://img.shields.io/badge/docs-workarounds-555?style=flat)](WORKAROUNDS.md)

Open archives as folders in Yazi on Linux. Browse them read-only or edit their contents and save changes to the archive

Leave an archive in every tab to unmount it. Edit mode keeps the original archive as `<name>.orig` and saves changes after Yazi exits too

## Install

```sh
ya pkg add rokokol/archive-mount
```

Add this to `init.lua`:

```lua
require("archive-mount"):setup()
```

Install `fuse-archive`, `archivemount`, FUSE 3, util-linux, GNU coreutils, and libnotify. Enable FUSE mounts for your user

For edit mode, use an archivemount-ng release with the [file truncation fix](https://git.sr.ht/~nabijaczleweli/archivemount-ng/commit/cf4300c). The Nix module supplies a fixed release

## Use

Add keys to `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = [ "<Space>", "a", "o" ]
run = "plugin archive-mount open"
desc = "Open archive read-only"

[[mgr.prepend_keymap]]
on = [ "<Space>", "a", "e" ]
run = "plugin archive-mount 'open --edit'"
desc = "Edit archive"
```

Hover an archive that Yazi recognizes, then use one of these keys. Edit support depends on the archive format and archivemount

## Home Manager

Add the flake input:

```nix
inputs.archive-mount-yazi = {
  url = "github:rokokol/archive-mount.yazi";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import its module into your home configuration:

```nix
{
  imports = [ inputs.archive-mount-yazi.homeModules.default ];
  programs.yazi.enable = true;
  programs.archive-mount-yazi.enable = true;
}
```

The module installs the plugin and its user-space dependencies, and calls `setup`. Configure FUSE and its privileged helper on the host. Add keys separately, as shown above
