{ lib, utils, spigot, ... }:

with lib; with utils; {
  submodule = types.submodule ({ ... }: {
    options = {
      enable = mkEnableOption "Enables lazymc reverse proxy";

      package = mkOption {
        type = types.package;
        default = spigot.lazymc;
        description = "Lazymc package";
      };
    };
  });

  generator = server:
    optionalAttrs server.lazymc.enable {
      # full config file -> https://github.com/timvisee/lazymc/blob/master/res/lazymc.toml
      "lazymc.toml" = utils.mkConfig "toml" {
        server.directory = server.datadir;
        server.command = "${server.datadir}/start.sh";
        # for some reason SIGKILL does not work, we use rcon
        rcon.enabled = true;
      };
    };
}
