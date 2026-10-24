# archive-mount.yazi

This repository contains a Yazi plugin for Linux. `main.lua` holds the plugin. `tests/` holds checks that run with Lua

`nix/package.nix` selects the files installed by both Nix and `ya pkg`. `nix/module.nix` owns plugin setup and runtime dependencies. Keep user keys outside the module

The plugin uses `/proc`, FUSE 3, and GNU tools. Do not claim support for another platform without a real mount test

Run the commands in [CONTRIBUTING.md](CONTRIBUTING.md) after changes. Build checks cannot verify FUSE mounts inside the Nix sandbox
