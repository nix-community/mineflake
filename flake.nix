{
  description = "Minecraft server in Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev: {
        mineflake = import ./pkgs {
          pkgs = prev;
          lib = prev.lib;
        };
      };

      devShells.x86_64-linux.default = import ./shell.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };

      packages.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        (self.overlays.default pkgs pkgs).mineflake;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };

        packages =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            overlay = (self.overlays.default pkgs pkgs).mineflake;
            buildInputs = builtins.filter (p: p ? outPath) (builtins.attrValues overlay);
          in
          (overlay // {
            # This is a hack to get the buildInputs of the overlay
            # Used for caching on cachix
            default = pkgs.stdenv.mkDerivation {
              name = "all";
              src = ./.;
              buildInputs = buildInputs;
              installPhase = "mkdir -p $out; echo '${toString buildInputs}' > $out/buildInputs";
            };
          });
      }
    );
}
