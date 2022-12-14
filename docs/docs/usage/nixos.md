# NixOS

Mineflake based on Nix, so running it on NixOS is easy.

## Add flake

``` nix title="flake.nix" hl_lines="5 15"
{
  inputs = {
    # ... your inputs ...
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mineflake.url = "github:nix-community/mineflake"; # (1)
  };
  outputs = { self, nixpkgs, mineflake, ... }:
    {
      nixosConfigurations = {
        your-machine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./your-machine.nix
            {
              nixpkgs.overlays = [ mineflake.overlays.default ];
            }
          ];
        };
      };
    }
}
```

1. For better caching we don't recommend using `mineflake.inputs.nixpkgs.follows = "nixpkgs";` in `flake.nix`.

### Customize overlay

You can customize overlay settings. For example, you can change default IPFS gateway:

``` nix title="flake.nix" hl_lines="15-19"
{
  inputs = {
    # ... your inputs ...
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mineflake.url = "github:nix-community/mineflake";
  };
  outputs = { self, nixpkgs, mineflake, ... }:
    {
      nixosConfigurations = {
        your-machine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./your-machine.nix
            {
              nixpkgs.overlays = [
                (mineflake.overlays.mineflakeWithCustomAttrs {
                  ipfsGateway = "https://ipfs.io/ipfs/";
                })
              ];
            }
          ];
        };
      };
    }
}
```

Currently, you can customize the following attributes:

- `ipfsGateway` - Path-based IPFS gateway to use for fetching dependencies. Default: `https://w3s.link/ipfs/`.
  [w3s.link](https://w3s.link/) is recommended gateway, because we host files in [web3.storage](https://web3.storage/).
