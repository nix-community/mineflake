{ pkgs, ... }:

with pkgs; {
  # Servers
  bungeecord = callPackage ./servers/bungeecord { };
  waterfall = callPackage ./servers/waterfall { };
}
