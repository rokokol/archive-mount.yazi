{
  lib,
  archivemount,
  fetchFromSourcehut,
}:

# Older releases ignore O_TRUNC and retain bytes after a shorter write; see WORKAROUNDS.md
let
  version = "1c";
in
if lib.versionAtLeast archivemount.version version then
  archivemount
else
  archivemount.overrideAttrs {
    inherit version;
    src = fetchFromSourcehut {
      owner = "~nabijaczleweli";
      repo = "archivemount-ng";
      rev = version;
      hash = "sha256-xz0lz++80B/Hkxw52UkrhUe4BhCevKW/IHoD+O5dXLw=";
    };
    meta = archivemount.meta // {
      changelog = "${archivemount.meta.homepage}/refs/${version}";
    };
  }
