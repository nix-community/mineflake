# Usage

Once you have installed mineflake you can start using it.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers.example = {
      localAddress = "192.168.100.2";
      plugins = with pkgs.mineflake; [ negativity lightchatbubbles ];
    };
  };
```

See options page, for a full description of all possible features

## Setting up Internet access

The systemd-nspawn containers do not configure the firewall in any additional way, unlike docker, so we need to configure the NAT ourselves.

```nix
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
  };
```

## Port forwarding

To open a port there is a special option forwardPorts

In the example above we open port 5000 and port 30000 which will be redirected to port 25565 inside the container.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers.example = {
      localAddress = "192.168.100.2";
      forwardPorts = [ "30000:25565", 5000 ];
    };
  };
```

## Bungeecord

Mineflake fully supports the functionality of bungeecord. Below is a minimal configuration with proxy server, lobby and game server.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers = {
      proxy = {
        localAddress = "192.168.100.2";
        forwardPorts = [ 25565 ];
        bungeecord = {
          enable = true;
          online_mode = false;
          servers = {
            lobby.address = "192.168.100.3";
            main.address = "192.168.100.4";
          };
          listeners = [
            {
              host = "0.0.0.0:25565";
              motd = "Some cool server!";
              priorities = [ "lobby" ];
            }
          ];
        };
      };
      lobby = {
        localAddress = "192.168.100.3";
        properties = {
          enable = true;
          online-mode = false;
        };
      };
      main = {
        localAddress = "192.168.100.4";
        properties = {
          enable = true;
          online-mode = false;
        };
      };
    };
  };
```

## Custom configs

Not all plugins have options written for them - as this is a long painful manual job. Instead, you can use a more low-level way to manage configs. In the example below, we enable sessions in AuthMe plugin.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers = {
      main = {
        localAddress = "192.168.100.2";
        plugins = [ pkgs.mineflake.authme ];
        configs = {
          "plugins/AuthMe/config.yml" = {
            type = "yaml";
            data = {
              settings.sessions.enabled = true;
            };
          };
        };
      };
    };
  };
```

## Default values

To avoid duplicate configurations between servers, the default option is provided - it will be merged with all servers unless otherwise specified. We already used this value when we set the hostAddress option.

In the example below, we will change the `language.yml` file of CoreProtect for all servers.

```nix
  minecraft = {
    enable = true;
    default = {
      hostAddress = "192.168.100.1";
      configs = {
        "plugins/CoreProtect/language.yml" = {
          type = "yaml";
          data = {
            TELEPORTED = "We changed config value in all servers! Teleported to {0}.";
          };
        };
      };
    };
    servers = {
      example1 = {
        localAddress = "192.168.100.2";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
      example2 = {
        localAddress = "192.168.100.3";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
      example3 = {
        useDefault = false; # On this server, we disabled the "default" merge, so the config will not be changed here, and the hostAddress option needs to be repeated.
        hostAddress = "192.168.100.1";
        localAddress = "192.168.100.4";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
    };
  };
```
