{ ... }:
with builtins;
let
  flake = (import (let lockFile = fromJSON (readFile ./flake.lock);
  in fetchTarball {
    url =
      "https://github.com/edolstra/flake-compat/archive/${lockFile.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lockFile.nodes.flake-compat.locked.narHash;
  }) { src = ./.; }).defaultNix;

  NIX_PATH = concatStringsSep ":" (attrValues (mapAttrs
    (n: v: if hasAttr "path" v then "${n}=${storePath v.path}" else "${n}=null")
    ((mapAttrs (n: v: getAttr currentSystem v) {
      nixpkgs = flake.outputs.nixpkgs;
      nixpkgs-unstable = flake.outputs.nixpkgs_latest;
    }))));

  TERM = "xterm";
  TMPDIR = "/tmp";

  nixpkgs = flake.nixpkgs.${currentSystem};
  nixpkgs_latest = flake.nixpkgs_latest.${currentSystem};
in nixpkgs.mkShell {
  name = "rules_cc_header_maps";

  inherit NIX_PATH TERM TMPDIR;

  buildInputs = with nixpkgs; [
    bazel_5
    cacert
    coreutils-full
    curlFull
    git
    gnutar
    nix
    nixfmt
    pkg-config
  ];

  shellHook = ''
    echo "Welcome to rules_cc_header_maps dev-shell."
  '';
}