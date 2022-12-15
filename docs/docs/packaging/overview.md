# Packaging

We use Nix to package plugins and server packages. This allows us declaratively compile packages and use them in Mineflake.

??? tip "You can use any tools to build packages"

    Mineflake is not limited to Nix.

## Introduction

Each package is simply a `package.yml` file, server type required files, and files that are copied to the server directory.

You can read more about package manifest in [manifest](manifest.md) page.

Example package file structure of AuthMe for `spigot`/`bungee` server type:

``` text
.
├── package.yml
├── package.jar -> plugins/${manifest.name}-${manifest.version}.jar (AuthMe-5.6.0-SNAPSHOT-b2467.jar, for example)
├── plugins
│   └── AuthMe
│       ├── config.yml -> plugins/AuthMe/config.yml
│       ├── messages.yml -> plugins/AuthMe/messages.yml
```

This package produced 3 files:

- `${manifest.name}-${manifest.version}.jar` - AuthMe plugin jar file.
- `plugins/AuthMe/config.yml` - AuthMe config file.
- `plugins/AuthMe/messages.yml` - AuthMe messages file.

Directories for files are created automatically. Directories is not copied to the server directory.

??? tip "Empty directories"

    If you want create a empty directory, you can create a empty file with `.keep` extension.

## Packaging with Nix

Usually you create a zip archive with all files and just download it.

``` nix linenums="1" title="package.nix"
{ mineflake, ... }:

mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "Qm..."; # (1)
    sha256 = "..."; # (2)
}
```

1. We use IPFS to store packages. You can use any other URL.

2. You can use `nix-prefetch-url --unpack ${url}` to get `sha256` hash.

But if package files are not statically-linked, you need to compile them.

``` nix linenums="1" title="package.nix"
{ mineflake, ... }:

mineflake.buildMineflakePackage { # (1)
    pname = "authme";
    version = "5.6.0-SNAPSHOT-b2467";
    # other parameters are passed to stdenv.mkDerivation
}
```

1. `buildMineflakePackage` is a function that simplifies package manifest creation.

???+ tip "You can use any Nix functions to build packages"

    You can use any Nix functions to build packages. For example, you can use `buildGoModule` to build Go packages.

    Only requirement is that you need to create a `package.yml` and server type required files.
