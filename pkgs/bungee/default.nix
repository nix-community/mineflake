{ pkgs, ... }:

with pkgs; {
  # Servers
  bungeecord = callPackage ./servers/bungeecord { };
  waterfall = callPackage ./servers/waterfall { };

  # Plugins
  authme = callPackage ./plugins/authme { };
  cleanmotd = callPackage ./plugins/cleanmotd { };
}
