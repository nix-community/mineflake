# Installing mineflake

## Add a flake

Mineflake can only be installed via flakes, so you must [enable them](https://nixos.wiki/wiki/Flakes) in your nix config. After you have enabled it, add a new input.

```nix
{
  description = "Your NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    mineflake.url = "git+https://git.frsqr.xyz/firesquare/mineflake?ref=main";
    mineflake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mineflake }:
    {
      nixosConfigurations = {
        example = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./example.nix
          ];
        };
      };
    };
}
```

## Update your nixosSystem

Add a new module and overlay nixpkgs to your nixosSystem.

```nix
{
  description = "Your NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    mineflake.url = "git+https://git.frsqr.xyz/firesquare/mineflake?ref=main";
    mineflake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mineflake }:
    {
      nixosConfigurations = {
        example = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./example.nix
            mineflake.nixosModules.default
            {
              nixpkgs.overlays = [ mineflake.overlays.default ];
            }
          ];
        };
      };
    };
}
```

Mineflake installed!
