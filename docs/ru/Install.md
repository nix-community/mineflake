# Установка mineflake

## Добавьте флэйк

Mineflake может быть установлен только через флэйки, поэтому вы должны включить их в конфигурации nix. После включения добавьте новый input.

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

## Обновите nixosSystem

Добавьте новый модуль и оверлей nixpkgs.

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

Mineflake установлен!
