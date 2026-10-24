{
  lib,
  pkgs,
  home-manager,
  self,
}:

let
  plugin = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
  root = builtins.path {
    name = "archive-mount-check-source";
    path = ../.;
  };
  wiring = import ./module-test.nix {
    inherit
      lib
      pkgs
      home-manager
      self
      ;
  };
in
{
  tests = pkgs.runCommand "archive-mount-tests" { nativeBuildInputs = with pkgs; [ lua5_5 ]; } ''
    lua ${root}/tests/unit.lua ${plugin}/main.lua
    lua ${root}/tests/entry.lua ${plugin}/main.lua
    test -f ${plugin}/LICENSE
    test -f ${plugin}/README.md
    test ! -e ${plugin}/tests
    test ! -e ${plugin}/flake.nix
    touch "$out"
  '';

  module-wiring =
    assert wiring;
    pkgs.runCommand "archive-mount-module-wiring" { } ''
      touch "$out"
    '';

  lint =
    pkgs.runCommand "archive-mount-lint"
      {
        nativeBuildInputs = with pkgs; [
          stylua
          luajitPackages.luacheck
        ];
      }
      ''
        cp -r ${root}/. .
        stylua --check main.lua tests
        luacheck main.lua tests
        touch "$out"
      '';

  metadata =
    pkgs.runCommand "archive-mount-metadata"
      {
        nativeBuildInputs = with pkgs; [
          bash
          git
          python3
        ];
      }
      ''
        cp -r ${root}/. .
        bash vendor-sync.sh check
        chmod u+w ./*.sh
        patchShebangs ./*.sh
        bash check-pins.sh
        bash check-changelog.sh
        bash check-prose.sh README.md CHANGELOG.md CONTRIBUTING.md CLAUDE.md
        touch "$out"
      '';

  nix-lint =
    pkgs.runCommand "archive-mount-nix-lint"
      {
        nativeBuildInputs = with pkgs; [
          bash
          deadnix
          git
          jq
          nix
          nixfmt
          statix
        ];
      }
      ''
        export HOME="$TMPDIR"
        cp -r ${root}/. .
        chmod -R u+w .
        patchShebangs ./*.sh
        bash check-nix.sh --static -C ${root} -N programs.archive-mount-yazi
        touch "$out"
      '';
}
