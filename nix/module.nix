{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.archive-mount-yazi.enable = lib.mkEnableOption "archive-mount.yazi";

  config = lib.mkIf config.programs.archive-mount-yazi.enable {
    programs.yazi = {
      plugins.archive-mount = {
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        setup = true;
      };
      # The host must supply a privileged FUSE helper; a store copy would hide it on PATH
      extraPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.archivemount
      ]
      ++ (with pkgs; [
        fuse-archive
        util-linux
        coreutils
        libnotify
      ]);
    };
  };
}
