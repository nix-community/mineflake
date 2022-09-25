# mineflake

[![license gpl3.0](https://img.shields.io/static/v1?label=License&message=GPL%203.0&color=FE7D37)](https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/LICENSE) [![ci/cd status](https://wp.frsqr.xyz/api/badges/firesquare/mineflake/status.svg)](https://wp.frsqr.xyz/firesquare/mineflake) [![matrix](https://img.shields.io/static/v1?label=Matrix&message=%23mineflake:matrix.org&color=GREEN)](https://matrix.to/#/#mineflake:matrix.org) [![read the wiki](https://img.shields.io/static/v1?label=Read%20The&message=Wiki&color=7C5D63)](https://git.frsqr.xyz/firesquare/mineflake/wiki) [![read the options](https://img.shields.io/static/v1?label=Read%20The&message=Options&color=8A2BE2)](https://mineflake.ipfsqr.ru/) [![gitea](https://img.shields.io/static/v1?label=Code%20on&message=Gitea&color=009C08&logo=gitea)](https://git.frsqr.xyz/firesquare/mineflake) [![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/@ebd31081-494e-4581-b228-7619d0fe1080/projects/vewdumcbno)

NixOS flake for easy declarative creation of minecraft server containers.

## Example configuration

```nix
minecraft = {
  enable = true;

  default.hostAddress = "192.168.100.1";

  servers = {
    proxy = {
      useDefault = false;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";
      bungeecord = {
        enable = true;
        online_mode = false;
        listeners = [
          {
            host = "0.0.0.0:25565";
            priorities = [ "lobby" ];
          }
        ];
        servers = {
          lobby.address = "192.168.100.3";
          main.address = "192.168.100.4";
        };
      };
      plugins = with pkgs.mineflake; [ cleanmotd authmebungee ];
      configs = {
        "plugins/AuthMeBungee/config.yml".data.authServers = [ "lobby" ];
        "plugins/CleanMotD/config.yml".data.motd.motds = [ "Cool server!" ];
      };
      package = pkgs.mineflake.waterfall;
    };

    lobby = {
      localAddress = "192.168.100.3";
      properties.enable = true;
      properties.online-mode = false;
      configs = {
        "plugins/AuthMe/config.yml".data.Hooks = {
          sendPlayerTo = "main";
          bungeecord = true;
          multiverse = false;
        };
      };
      plugins = with pkgs.mineflake; [ authme essentialsx ];
    };

    main = {
      localAddress = "192.168.100.4";
      properties.enable = true;
      properties.online-mode = false;
      plugins = with pkgs.mineflake; [ coreprotect essentialsx ];
    };
  };
};
```

## [Read the docs!](https://git.frsqr.xyz/firesquare/mineflake/wiki)
