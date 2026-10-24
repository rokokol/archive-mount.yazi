{ lib, yaziPlugins }:

yaziPlugins.mkYaziPlugin {
  pname = "archive-mount.yazi";
  version = lib.fileContents ../VERSION;
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../main.lua
      ../LICENSE
      ../README.md
    ];
  };

  meta = {
    description = "Yazi plugin that opens archives as folders";
    homepage = "https://github.com/rokokol/archive-mount.yazi";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
