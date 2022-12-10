{ pkgs, ... }:

with pkgs; rec {
  buildMineflakeBin = config: writeScriptBin "mineflake" ''
    #!${pkgs.runtimeShell}
    ${mineflake}/bin/mineflake "${builtins.toFile "config.json" (builtins.toJSON config)}"
  '';

  mineflake = callPackage ../cli { };

  # Alias to mineflake for `nix build .` command
  default = mineflake;
}
