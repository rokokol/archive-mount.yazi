{
  lib,
  pkgs,
  home-manager,
  self,
}:

let
  plugin = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
  home =
    enabled:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeModules.default
        {
          home = {
            username = "test";
            homeDirectory = "/home/test";
            stateVersion = "26.05";
          };
          programs = {
            yazi = {
              enable = true;
              plugins.sentinel = plugin;
            };
            archive-mount-yazi.enable = enabled;
          };
        }
      ];
    };
  enabled = (home true).config.programs.yazi;
  disabled = (home false).config.programs.yazi;
in
assert lib.assertMsg (
  enabled.plugins.archive-mount.package == plugin
) "The module must install its plugin";
assert lib.assertMsg enabled.plugins.archive-mount.setup "The module must call setup";
assert lib.assertMsg (enabled.plugins ? sentinel) "Other plugin definitions must survive the merge";
assert lib.assertMsg (
  !(disabled.plugins ? archive-mount)
) "A disabled module must not install its plugin";
assert lib.assertMsg (disabled.extraPackages == [ ]) "A disabled module must not add dependencies";
assert lib.assertMsg (lib.all (package: lib.elem package enabled.extraPackages) (
  with pkgs;
  [
    fuse-archive
    util-linux
    coreutils
    libnotify
  ]
)) "The module must supply all runtime dependencies";
assert lib.assertMsg (lib.elem self.packages.${pkgs.stdenv.hostPlatform.system}.archivemount
  enabled.extraPackages
) "The module must use the backend with correct file truncation";
assert lib.assertMsg (
  !(lib.elem pkgs.fuse3 enabled.extraPackages)
) "The module must not hide the privileged system FUSE helper";
true
