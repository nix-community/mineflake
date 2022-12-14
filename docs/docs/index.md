# Mineflake

Mineflake is a tool for creating and managing Minecraft servers declaratively. It is written in Rust and uses Nix for package management.

[![license MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=FE7D37)](https://github.com/nix-community/mineflake/blob/main/LICENSE)
[![matrix](https://img.shields.io/static/v1?label=Matrix&message=%23mineflake:matrix.org&color=GREEN)](https://matrix.to/#/#mineflake:matrix.org)
[![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/@ebd31081-494e-4581-b228-7619d0fe1080/projects/vewdumcbno)
[![Cache derivations](https://github.com/nix-community/mineflake/actions/workflows/build.yml/badge.svg)](https://github.com/nix-community/mineflake/actions/workflows/build.yml)

---

**Source code**: [https://github.com/nix-community/mineflake](https://github.com/nix-community/mineflake)

---

## Quick start

Mineflake can be used with Nix or without it. To use Mineflake without Nix, you need to install Rust and Cargo. To do so, run:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install mineflake
```

If you want to use Mineflake with Nix, you need to install Nix. To do so, run:

```bash
bash <(curl -L https://nixos.org/nix/install)
```

???+ info "Which method I should use?"

    If you are familiar with Nix, you should use Nix. If you are not, you should use Cargo.

    With Nix you get more control. Both methods have same package set and same features.

??? note "Note about NixOS"

    If you are using NixOS, you don't need to install Nix. It is already installed.

### Installation

To debug Mineflake confirurations it is recommended to install CLI. To do so, run:

=== "With Nix"

    ``` bash
    nix run github:nix-community/mineflake
    ```

=== "With Cargo"

    ``` bash
    cargo install mineflake
    ```

### Example configuration

To use example Docker configuration, run:

```bash
nix flake init --template github:nix-community/mineflake
```
