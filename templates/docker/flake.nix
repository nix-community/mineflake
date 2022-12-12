{
  description = "Mineflake-powered Minecraft server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mineflake = {
      url = "github:nix-community/mineflake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, mineflake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ mineflake.overlays.default ];
        };
      in
      {
        packages = rec {
          docker = pkgs.callPackage ./docker.nix { };
          default = docker;
        };
      });
}
