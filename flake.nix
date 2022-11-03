{
  description = "Minecraft server in Nix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    {
      nixosModules.default = import ./modules;

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
    };
}
