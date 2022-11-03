{ config, pkgs, lib, ... }:


with lib;
let
  cfg = config.services.mineflake;
in
{
  options = {
    services.mineflake = mkOption {
      type = types.attrs;
      default = {
        enable = false;
      };
      description = ''
        Mineflake configuration.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc."mineflake.json".text = builtins.toJSON cfg;
  };
}
