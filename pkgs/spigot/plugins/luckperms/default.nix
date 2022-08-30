{ lib, stdenv, fetchzip, ... }:

let
  hash = "sha256-PoCUj536ApYR5Chw/jiabPHspVtzdIAL1rUSgPn6KyA=";
  url = "https://static.ipfsqr.ru/ipfs/bafybeidlkbnqjddmsowjmbvrfrt7b54qqjxwrlmtvmdfpah5qqo72rvxvm/luckperms-spigot.tar.gz";
  src = fetchzip {
    url = url;
    hash = hash;
  };
in
stdenv.mkDerivation {
  inherit hash src;

  pname = "LuckPerms";
  version = "5.4";

  preferLocalBuild = true;

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/libs
    install -Dm444 $src/LuckPerms-Bukkit-*.jar $out/result
    install -Dm444 $src/libs/*.jar $out/libs
  '';

  meta = with lib; {
    description = "A permissions plugin for Minecraft servers";
    longDescription = ''
      LuckPerms is a permissions plugin for Minecraft servers. It allows server admins to control what features
      players can use by creating groups and assigning permissions.

      It is:
        fast - written with performance and scalability in mind.
        reliable - trusted by thousands of server admins, and the largest of server networks.
        easy to use - setup permissions using commands, directly in config files, or using the web editor.
        flexible - supports a variety of data storage options, and works on lots of different server types.
        extensive - a plethora of customization options and settings which can be changed to suit your server.
        free - available for download and usage at no cost, and permissively licensed so it can remain free forever.
    '';
    homepage = "https://luckperms.net/";
    license = licenses.mit;
    platforms = platforms.all;
    configs = {
      "plugins/LuckPerms/config.yml" = {
        type = "yaml";
        data = {
          "server" = "global";
          "use-server-uuid-cache" = false;
          "storage-method" = "h2";
          "data" = {
            "address" = "localhost";
            "database" = "minecraft";
            "username" = "root";
            "password" = "";
            "pool-settings" = {
              "maximum-pool-size" = 10;
              "minimum-idle" = 10;
              "maximum-lifetime" = 1800000;
              "keepalive-time" = 0;
              "connection-timeout" = 5000;
              "properties" = {
                "useUnicode" = true;
                "characterEncoding" = "utf8";
              };
            };
            "table-prefix" = "luckperms_";
            "mongodb-collection-prefix" = "";
            "mongodb-connection-uri" = "";
          };
          "split-storage" = {
            "enabled" = false;
            "methods" = {
              "user" = "h2";
              "group" = "h2";
              "track" = "h2";
              "uuid" = "h2";
              "log" = "h2";
            };
          };
          "sync-minutes" = -1;
          "watch-files" = true;
          "messaging-service" = "auto";
          "auto-push-updates" = true;
          "push-log-entries" = true;
          "broadcast-received-log-ntries" = true;
          "redis" = {
            "enabled" = false;
            "address" = "localhost";
            "username" = "";
            "password" = "";
          };
          "rabbitmq" = {
            "enabled" = false;
            "address" = "localhost";
            "vhost" = "/";
            "username" = "guest";
            "password" = "guest";
          };
          "temporary-add-behaviour" = "deny";
          "primary-group-calculation" = "parents-by-weight";
          "argument-based-command-permissions" = false;
          "require-sender-group-membership-to-modify" = false;
          "log-notify" = true;
          "log-notify-filtered-descriptions" = null;
          "auto-install-translations" = true;
          "meta-formatting" = {
            "prefix" = {
              "format" = [
                "highest"
              ];
              "duplicates" = "first-only";
              "start-spacer" = "";
              "middle-spacer" = " ";
              "end-spacer" = "";
            };
            "suffix" = {
              "format" = [
                "highest"
              ];
              "duplicates" = "first-only";
              "start-spacer" = "";
              "middle-spacer" = " ";
              "end-spacer" = "";
            };
          };
          "inheritance-traversal-algorithm" = "depth-first-pre-order";
          "post-traversal-inheritance-sort" = false;
          "context-satisfy-mode" = "at-least-one-value-per-key";
          "disabled-contexts" = null;
          "include-global" = true;
          "include-global-world" = true;
          "apply-global-groups" = true;
          "apply-global-world-groups" = true;
          "meta-value-selection-default" = "inheritance";
          "meta-value-selection" = null;
          "apply-wildcards" = true;
          "apply-sponge-implicit-wildcards" = false;
          "apply-default-negated-permissions-before-wildcards" = false;
          "apply-regex" = true;
          "apply-shorthand" = true;
          "apply-bukkit-child-permissions" = true;
          "apply-bukkit-default-permissions" = true;
          "apply-bukkit-attachment-permissions" = true;
          "disabled-context-calculators" = [ ];
          "world-rewrite" = null;
          "group-weight" = null;
          "enable-ops" = false;
          "auto-op" = false;
          "commands-allow-op" = false;
          "vault-unsafe-lookups" = false;
          "vault-group-use-displaynames" = true;
          "vault-npc-group" = "default";
          "vault-npc-op-status" = false;
          "use-vault-server" = false;
          "vault-server" = "global";
          "vault-include-global" = true;
          "vault-ignore-world" = false;
          "debug-logins" = false;
          "allow-invalid-usernames" = false;
          "skip-bulkupdate-confirmation" = false;
          "disable-bulkupdate" = false;
          "prevent-primary-group-removal" = false;
          "update-client-command-list" = true;
          "register-command-list-data" = true;
          "resolve-command-selectors" = false;
        };
      };
    };
    server = "spigot";
    type = "complex";
    deps = [ ];
    struct = builtins.listToAttrs (map (entry: { name = "plugins/LuckPerms/libs/${entry}"; value = "libs/${entry}"; }) [
      "adventure-platform-bukkit-4.11.2-remapped.jar"
      "mongodb-driver-legacy-4.5.0-remapped.jar"
      "adventure-platform-4.11.2-remapped.jar"
      "mongodb-driver-bson-4.5.0-remapped.jar"
      "mongodb-driver-core-4.5.0-remapped.jar"
      "mongodb-driver-sync-4.5.0-remapped.jar"
      "postgresql-driver-42.2.19-remapped.jar"
      "adventure-platform-bukkit-4.11.2.jar"
      "configurate-hocon-3.7.2-remapped.jar"
      "configurate-core-3.7.2-remapped.jar"
      "configurate-gson-3.7.2-remapped.jar"
      "configurate-yaml-3.7.2-remapped.jar"
      "configurate-toml-3.7-remapped.jar"
      "mysql-driver-8.0.23-remapped.jar"
      "bytebuddy-1.10.22-remapped.jar"
      "commodore-file-1.0-remapped.jar"
      "hocon-config-1.4.1-remapped.jar"
      "mongodb-driver-legacy-4.5.0.jar"
      "adventure-4.11.0-remapped.jar"
      "adventure-platform-4.11.2.jar"
      "mongodb-driver-bson-4.5.0.jar"
      "mongodb-driver-core-4.5.0.jar"
      "mongodb-driver-sync-4.5.0.jar"
      "postgresql-driver-42.2.19.jar"
      "caffeine-2.9.0-remapped.jar"
      "commodore-2.2-remapped.jar"
      "configurate-hocon-3.7.2.jar"
      "configurate-core-3.7.2.jar"
      "configurate-gson-3.7.2.jar"
      "configurate-yaml-3.7.2.jar"
      "okhttp-3.14.9-remapped.jar"
      "hikari-4.0.3-remapped.jar"
      "toml4j-0.7.2-remapped.jar"
      "configurate-toml-3.7.jar"
      "event-3.0.0-remapped.jar"
      "okio-1.17.5-remapped.jar"
      "sqlite-driver-3.28.0.jar"
      "commodore-file-1.0.jar"
      "mysql-driver-8.0.23.jar"
      "bytebuddy-1.10.22.jar"
      "hocon-config-1.4.1.jar"
      "adventure-4.11.0.jar"
      "h2-driver-1.4.199.jar"
      "jar-relocator-1.4.jar"
      "asm-commons-9.1.jar"
      "caffeine-2.9.0.jar"
      "commodore-2.2.jar"
      "okhttp-3.14.9.jar"
      "hikari-4.0.3.jar"
      "toml4j-0.7.2.jar"
      "event-3.0.0.jar"
      "okio-1.17.5.jar"
      "asm-9.1.jar"
    ]);
    folders = [
      "plugins/LuckPerms"
      "plugins/LuckPerms/libs"
      "plugins/LuckPerms/json-storage"
      "plugins/LuckPerms/json-storage/groups"
    ];
  };
}
