# How mineflake works

## NixOS

Mineflake relies on NixOS, which gives us a reliable system and atomic updates with simple rollbacks, and its Nix package manager which allows you to create fully repeatable packages. Nix, when it downloads dependencies (plugins, other packages which are needed to build plugins) and builds the result, cryptographically hashes them and puts them in `/nix/store` , its repository with all the packages.

When we start the rebuild process Nix will create preconfigured configs and load server dependencies.

## Containers

After Nix has downloaded and built containers, containers - isolated lightweight virtual machines - come into play. We use containers not for the isolation of dependencies (this is what Nix provides by itself) but for security - ports are limited, the Internet can be disabled, an extra level of abstraction for viruses and hackers. The container contains another NixOS system but with our `/nix/store`.

## Boot script

After the container is running, the boot script starts. Its purpose is simple - to prepare a place to start our server. It creates folders, carefully puts configs in their folders, replaces secrets in them, links from `/nix/store` our plugins and starts the server.
