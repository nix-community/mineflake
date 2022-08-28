{ lib, utils, ... }:

with lib; with utils; {
  submodule = types.submodule ({ ... }: {
    options = {
      enable = mkEnableOption "Enables declarative generation of Bungeecord settings";

      online_mode = mkOption {
        type = types.bool;
        default = true;
      };

      ip_forward = mkOption {
        type = types.bool;
        default = false;
      };

      log_pings = mkOption {
        type = types.bool;
        default = false;
      };

      forge_support = mkOption {
        type = types.bool;
        default = false;
      };

      connection_throttle = mkOption {
        type = types.ints.positive;
        default = 4000;
      };

      remote_ping_cache = mkOption {
        type = types.int;
        default = -1;
      };

      player_limit = mkOption {
        type = types.int;
        default = -1;
      };

      timeout = mkOption {
        type = types.int;
        default = 30000;
      };

      servers = mkOption {
        type = types.attrsOf (types.submodule ({ ... }: {
          options = {
            motd = mkOption {
              type = types.str;
              default = "Just another mineflake server!";
            };

            address = mkOption {
              type = types.str;
            };

            restricted = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }));
        example = {
          lobby.address = "192.168.100.3:25565";
        };
      };

      listeners = mkOption {
        type = types.listOf (types.submodule ({ ... }: {
          options = {
            query_port = mkOption {
              type = types.port;
              default = 25565;
            };

            query_enabled = mkOption {
              type = types.bool;
              default = false;
            };

            proxy_protocol = mkOption {
              type = types.bool;
              default = false;
            };

            ping_passthrough = mkOption {
              type = types.bool;
              default = false;
            };

            bind_local_address = mkOption {
              type = types.bool;
              default = true;
            };

            force_default_server = mkOption {
              type = types.bool;
              default = false;
            };

            forced_hosts = mkOption {
              type = types.attrsOf types.str;
              default = {};
            };

            motd = mkOption {
              type = types.str;
              default = "Just another mineflake server!";
            };

            tab_list = mkOption {
              type = types.str;
              default = "GLOBAL_PING";
            };

            priorities = mkOption {
              type = types.listOf types.str;
              default = [];
            };

            host = mkOption {
              type = types.str;
            };

            max_players = mkOption {
              type = types.ints.positive;
              default = 1;
            };

            tab_size = mkOption {
              type = types.ints.positive;
              default = 60;
            };
          };
        }));
        example = [
          {
            host = "0.0.0.0:25565";
            motd = "Some cool server!";
            priorities = [ "lobby" ];
          }
        ];
      };
    };
  });

  generator = bungeecord:
    optionalAttrs bungeecord.enable {
      "config.yml" = mkConfig "yaml" {
        connection_throttle = bungeecord.connection_throttle;
        remote_ping_cache = bungeecord.remote_ping_cache;
        forge_support = bungeecord.forge_support;
        player_limit = bungeecord.player_limit;
        online_mode = bungeecord.online_mode;
        ip_forward = bungeecord.ip_forward;
        log_pings = bungeecord.log_pings;
        listeners = bungeecord.listeners;
        timeout = bungeecord.timeout;
        servers = bungeecord.servers;
      };
    };
}
