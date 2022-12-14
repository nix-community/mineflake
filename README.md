# Mineflake

[![Support Ukraine](https://badgen.net/badge/support/UKRAINE/?color=0057B8&labelColor=FFD700)](https://www.gov.uk/government/news/ukraine-what-you-can-do-to-help)
[![license MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=FE7D37)](https://github.com/nix-community/mineflake/blob/main/LICENSE)
[![matrix](https://img.shields.io/static/v1?label=Matrix&message=%23mineflake:matrix.org&color=GREEN)](https://matrix.to/#/#mineflake:matrix.org)
[![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/@ebd31081-494e-4581-b228-7619d0fe1080/projects/vewdumcbno)
[![Cache derivations](https://github.com/nix-community/mineflake/actions/workflows/build.yml/badge.svg)](https://github.com/nix-community/mineflake/actions/workflows/build.yml)

NixOS flake for easy declarative creation of minecraft server containers.

## Examples

### Docker container with a Paper and AuthMe

```nix
{ pkgs, ... }:

with pkgs; mineflake.buildMineflakeContainer {
  package = mineflake.paper;
  command = "${jdk}/bin/java -Xms1G -Xmx1G -jar {} nogui";
  plugins = with mineflake; [ luckperms ];
  configs = [
    (mineflake.mkMfConfig "mergeyaml" "plugins/LuckPerms/config.yml" {
      server = "vanilla_1";
    })
  ];
}
```

## Installation

Install Nix:

```sh
bash <(curl -L https://nixos.org/nix/install)
```

Install Cachix and add the mineflake cache to speed up builds (optional):

```sh
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use nix-community
```

Initialize the flake:

```sh
nix flake init --template github:nix-community/mineflake
```

## Contributing

You can read the [contributing guide](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

In short, you can do whatever you want with this project. You must include the license file
with your distribution, but you don't have to include the source code. But if you include a
link to the original project, the author will be immensely pleased.

In addition, this project uses the following third-party software:

- [nixpkgs](https://github.com/NixOS/nixpkgs) - Licensed under the
  [MIT](https://github.com/NixOS/nixpkgs/blob/master/COPYING).
  Used as a package repository.
- [rust-overlay](https://github.com/oxalica/rust-overlay) - Licensed under the
  [MIT](https://github.com/oxalica/rust-overlay/blob/master/LICENSE).
  Used to set up the Rust toolchain in developer environment.
- [naersk](https://github.com/nix-community/naersk) - Licensed under the
  [MIT](https://github.com/nix-community/naersk/blob/master/LICENSE).
  Used to build Mineflake CLI.
- [flake-utils](https://github.com/numtide/flake-utils) - Licensed under the
  [MIT](https://github.com/numtide/flake-utils/blob/master/LICENSE).
  Simplifies the creation of flake outputs.

## Contributors

If you contribute to this project, please add your name to the list below.

- [cofob](https://github.com/cofob) - Author and maintainer

## Sponsors and sponsorship

If you want to support this project author directly, you can donate with cryptocurrency:

- Tron: `TH2DAzhpe82TmwnhdtgDsyExTT1BBgpkyD`
- Monero: `8B33vTVddZFitR33QY3bWe2tq4Q7o1ajdAz4wx831kr9e13fXTC14ur6caPYXm5fnijjsZ1aXvGvMFx2B1YgowWHJbfgcxQ`
- Bitcoin: `bc1qcqqh02ctvq5z2v5ksv9rc0fza4gpr3pqy3uhdf`
- Ethereum: `0xB2c854EBC480FB7cE9Be5f0dcD63F897ca49961b`

Please notify the author about your donation by sending a message to the telegram
[@cofob](https://t.me/cofob) or by email [cofob@riseup.net](mailto:cofob@riseup.net)
and your name will be added to the list of sponsors.
