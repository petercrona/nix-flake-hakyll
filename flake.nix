{
  description = "Hakyll with Nix";

  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = self: _: {
          hsPkgs =
            self.haskell-nix.project' rec {
              src = ./.;
              compiler-nix-name = "ghc8107";
            };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            haskellNix.overlay
            overlay
          ];
        };
        flake = pkgs.hsPkgs.flake { };
      in
        flake // {
          packages.default = flake.packages."blog:exe:site";
          apps.default = {
            type = "app";
            program = "${flake.packages."blog:exe:site"}/bin/site";
          };
        }
    );
}
