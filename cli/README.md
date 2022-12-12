# Mineflake CLI

Mineflake CLI is a command line interface for [Mineflake](https://github.com/nix-community/mineflake).
It is used internally by the Mineflake to build and run the Mineflake servers.

You can use it to debug Mineflake configurations, or use separately from Nix and NixOS.

If you have Nix installed, you can try Mineflake CLI without installing it:

```sh
nix run github:nix-community/mineflake -- help
```

## Features

- cli: *(enabled by default)* Enable dependencies for the CLI. Disable this if you only want to use the Mineflake library.
- net: *(enabled by default)* Enable net module and remote package fetching (requires openssl).

## Windows

Mineflake CLI is not tested on Windows, but it should work. (If you have a Windows machine, please test it and report any issues!)
