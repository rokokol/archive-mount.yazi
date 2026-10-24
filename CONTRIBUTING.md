# Contribute

Explain the problem and the expected behavior in an issue or pull request. Keep each change focused on one problem

Run these checks before you submit a change:

```sh
nix flake check
nix fmt -- --ci
nix develop --command bash check-nix.sh -N programs.archive-mount-yazi
```

For mount changes, also test with real archives and FUSE on Linux. Check read-only access, saved edits, open tabs, and exit cleanup
