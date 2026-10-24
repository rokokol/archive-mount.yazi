# Workarounds

Temporary package overrides for defects in dependencies. Each entry gives a removal check

---

## Archive edits use a backend with correct file truncation

**Where:** `nix/archivemount.nix`, selected by the Home Manager module and the development shell on Linux

**Symptom it prevents:** a shorter write leaves bytes from the old file in both the mount and the saved archive. A write of `edited\n` over `original\n` produces `edited\nl\n`

**Why it happens:** the older backend does not handle `O_TRUNC` in its open callback. Yazi does not perform the file write

**Why this works:** the package expression sets a minimum backend version and keeps the caller's package when it meets that minimum. Otherwise, it builds the fixed upstream release with the nixpkgs recipe

**Removal check:** inspect the backend version from the locked nixpkgs input

```sh
nix eval --raw --inputs-from . nixpkgs#archivemount.version
```

Compare it with the minimum in `nix/archivemount.nix`. An older version requires the fallback. Once nixpkgs supplies the fix, remove the fallback after a real archive test confirms shorter writes and saved edits

**Upstream:** [archivemount-ng file truncation fix](https://git.sr.ht/~nabijaczleweli/archivemount-ng/commit/cf4300c), released; [NixOS/nixpkgs#568066](https://github.com/NixOS/nixpkgs/pull/568066), open
