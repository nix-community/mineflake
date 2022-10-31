# mineflake

[![license MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=FE7D37)](https://github.com/nix-community/mineflake/blob/main/LICENSE)
[![matrix](https://img.shields.io/static/v1?label=Matrix&message=%23mineflake:matrix.org&color=GREEN)](https://matrix.to/#/#mineflake:matrix.org)
[![read the options](https://img.shields.io/static/v1?label=Read%20The&message=Options&color=8A2BE2)](https://nix-community.github.io/mineflake/)
[![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/@ebd31081-494e-4581-b228-7619d0fe1080/projects/vewdumcbno)

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

## Contributing

You can read the [contributing guide](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

In short, you can do whatever you want with this project. You must include the license file
with your distribution, but you don't have to include the source code. But if you include a
link to the original project, the author will be immensely pleased.

In addition, this project uses the following third-party software:

- [nixpkgs](https://github.com/NixOS/nixpkgs) - Licensed under the
  [MIT License](https://github.com/NixOS/nixpkgs/blob/master/COPYING).

## Contributors

If you contribute to this project, please add your name to the list below.

- [cofob](https://t.me/cofob) - Author and maintainer
