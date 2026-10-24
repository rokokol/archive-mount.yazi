{
  description = "A Yazi plugin that opens archives as folders on Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        default = archive-mount;
        archive-mount = pkgs.callPackage ./nix/package.nix { };
        archivemount = pkgs.callPackage ./nix/archivemount.nix { };
      });

      homeModules.default = import ./nix/module.nix { inherit self; };
      homeManagerModules.default = self.homeModules.default;

      overlays.default = final: prev: {
        yaziPlugins = prev.yaziPlugins // {
          inherit (self.packages.${final.stdenv.hostPlatform.system}) archive-mount;
        };
      };

      checks = forAllSystems (
        pkgs:
        import ./nix/checks.nix {
          inherit
            lib
            pkgs
            home-manager
            self
            ;
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            lua5_5
            stylua
            luajitPackages.luacheck
            nixfmt
            statix
            deadnix
            jq
            git
            nix
            python3
            fuse-archive
            self.packages.${pkgs.stdenv.hostPlatform.system}.archivemount
            util-linux
            coreutils
            libnotify
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
