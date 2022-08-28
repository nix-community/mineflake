{ lib, utils, ... }:

with lib; with utils; {
  submodule = types.submodule ({ ... }: {
    options = {
      enable = mkEnableOption "Enables declarative generation of server.properties";

      allow-flight = mkOption {
        type = types.bool;
        default = false;
      };

      allow-nether = mkOption {
        type = types.bool;
        default = true;
      };

      broadcast-console-to-ops = mkOption {
        type = types.bool;
        default = true;
      };

      broadcast-rcon-to-ops = mkOption {
        type = types.bool;
        default = true;
      };

      debug = mkOption {
        type = types.bool;
        default = false;
      };

      difficulty = mkOption {
        type = types.enum [ "easy" "hard" ];
        default = "easy";
      };

      enable-command-block = mkOption {
        type = types.bool;
        default = false;
      };

      enable-jmx-monitoring = mkOption {
        type = types.bool;
        default = false;
      };

      enable-query = mkOption {
        type = types.bool;
        default = false;
      };

      enable-rcon = mkOption {
        type = types.bool;
        default = false;
      };

      enable-status = mkOption {
        type = types.bool;
        default = true;
      };

      enforce-whitelist = mkOption {
        type = types.bool;
        default = false;
      };

      entity-broadcast-range-percentage = mkOption {
        type = types.int;
        default = 100;
      };

      force-gamemode = mkOption {
        type = types.bool;
        default = false;
      };

      function-permission-level = mkOption {
        type = types.ints.positive;
        default = 2;
      };

      gamemode = mkOption {
        type = types.enum [ "survival" "creative" "spectator" ];
        default = "survival";
      };

      generate-structures = mkOption {
        type = types.bool;
        default = true;
      };

      generator-settings = mkOption {
        type = types.str;
        default = "{}";
      };

      hardcore = mkOption {
        type = types.bool;
        default = false;
      };

      hide-online-players = mkOption {
        type = types.bool;
        default = false;
      };

      level-name = mkOption {
        type = types.str;
        default = "world";
      };

      level-seed = mkOption {
        type = types.str;
        default = "";
      };

      level-type = mkOption {
        type = types.str;
        default = "default";
      };

      max-players = mkOption {
        type = types.ints.positive;
        default = 20;
      };

      max-tick-time = mkOption {
        type = types.ints.positive;
        default = 60000;
      };

      max-world-size = mkOption {
        type = types.ints.positive;
        default = 29999984;
      };

      motd = mkOption {
        type = types.str;
        default = "A Mineflake Server";
      };

      network-compression-threshold = mkOption {
        type = types.int;
        default = 256;
      };

      online-mode = mkOption {
        type = types.bool;
        default = true;
      };

      op-permission-level = mkOption {
        type = types.int;
        default = 4;
      };

      player-idle-timeout = mkOption {
        type = types.int;
        default = 0;
      };

      prevent-proxy-connections = mkOption {
        type = types.bool;
        default = false;
      };

      pvp = mkOption {
        type = types.bool;
        default = true;
      };

      query-port = mkOption {
        type = types.port;
        default = 25565;
      };

      rate-limit = mkOption {
        type = types.int;
        default = 0;
      };

      rcon-password = mkOption {
        type = types.str;
        default = "";
      };

      rcon-port = mkOption {
        type = types.port;
        default = 25575;
      };

      require-resource-pack = mkOption {
        type = types.bool;
        default = false;
      };

      resource-pack-prompt = mkOption {
        type = types.str;
        default = "";
      };

      resource-pack-sha1 = mkOption {
        type = types.str;
        default = "";
      };

      resource-pack = mkOption {
        type = types.str;
        default = "";
      };

      server-ip = mkOption {
        type = types.str;
        default = "";
      };

      server-port = mkOption {
        type = types.port;
        default = 25565;
      };

      simulation-distance = mkOption {
        type = types.int;
        default = 10;
      };

      spawn-animals = mkOption {
        type = types.bool;
        default = true;
      };

      spawn-monsters = mkOption {
        type = types.bool;
        default = true;
      };

      spawn-npcs = mkOption {
        type = types.bool;
        default = true;
      };

      spawn-protection = mkOption {
        type = types.ints.unsigned;
        default = 16;
      };

      sync-chunk-writes = mkOption {
        type = types.bool;
        default = true;
      };

      text-filtering-config = mkOption {
        type = types.str;
        default = "";
      };

      use-native-transport = mkOption {
        type = types.bool;
        default = true;
      };

      view-distance = mkOption {
        type = types.ints.positive;
        default = 10;
      };

      white-list = mkOption {
        type = types.bool;
        default = false;
      };
    };
  });

  generator = properties: optionalAttrs properties.enable {
    "server.properties" = utils.mkRawConfig ''
      allow-flight=${boolToString properties.allow-flight}
      allow-nether=${boolToString properties.allow-nether}
      broadcast-console-to-ops=${boolToString properties.broadcast-console-to-ops}
      broadcast-rcon-to-ops=${boolToString properties.broadcast-rcon-to-ops}
      debug=${boolToString properties.debug}
      difficulty=${properties.difficulty}
      enable-command-block=${boolToString properties.enable-command-block}
      enable-jmx-monitoring=${boolToString properties.enable-jmx-monitoring}
      enable-query=${boolToString properties.enable-query}
      enable-rcon=${boolToString properties.enable-rcon}
      enable-status=${boolToString properties.enable-status}
      enforce-whitelist=${boolToString properties.enforce-whitelist}
      entity-broadcast-range-percentage=${toString properties.entity-broadcast-range-percentage}
      force-gamemode=${boolToString properties.force-gamemode}
      function-permission-level=${toString properties.function-permission-level}
      gamemode=${properties.gamemode}
      generate-structures=${boolToString properties.generate-structures}
      generator-settings=${properties.generator-settings}
      hardcore=${boolToString properties.hardcore}
      hide-online-players=${boolToString properties.hide-online-players}
      level-name=${properties.level-name}
      level-seed=${properties.level-seed}
      level-type=${properties.level-type}
      max-players=${toString properties.max-players}
      max-tick-time=${toString properties.max-tick-time}
      max-world-size=${toString properties.max-world-size}
      motd=${properties.motd}
      network-compression-threshold=${toString properties.network-compression-threshold}
      online-mode=${boolToString properties.online-mode}
      op-permission-level=${toString properties.op-permission-level}
      player-idle-timeout=${toString properties.player-idle-timeout}
      prevent-proxy-connections=${boolToString properties.prevent-proxy-connections}
      pvp=${boolToString properties.pvp}
      query.port=${toString properties.query-port}
      rate-limit=${toString properties.rate-limit}
      rcon.password=${properties.rcon-password}
      rcon.port=${toString properties.rcon-port}
      require-resource-pack=${boolToString properties.require-resource-pack}
      resource-pack-prompt=${properties.resource-pack-prompt}
      resource-pack-sha1=${properties.resource-pack-sha1}
      resource-pack=${properties.resource-pack}
      server-ip=${properties.server-ip}
      server-port=${toString properties.server-port}
      simulation-distance=${toString properties.simulation-distance}
      spawn-animals=${boolToString properties.spawn-animals}
      spawn-monsters=${boolToString properties.spawn-monsters}
      spawn-npcs=${boolToString properties.spawn-npcs}
      spawn-protection=${toString properties.spawn-protection}
      sync-chunk-writes=${boolToString properties.sync-chunk-writes}
      text-filtering-config=${properties.text-filtering-config}
      use-native-transport=${boolToString properties.use-native-transport}
      view-distance=${toString properties.view-distance}
      white-list=${boolToString properties.white-list}
    '';
  };
}
