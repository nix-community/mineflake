{ pkgs, ... }:

with pkgs; {
  # MUST BE SORTED! (you can use "Sort Lines" vs code plugin with "Natural" sorting)

  # Utils
  lazymc = callPackage ./other/lazymc { };
  utils = callPackage ./other/utils { };

  # Servers
  bungeecord = callPackage ./servers/bungeecord { };
  paper = callPackage ./servers/paper_1.18.2 { };
  paper_1_18_2 = callPackage ./servers/paper_1.18.2 { };
  waterfall = callPackage ./servers/waterfall { };

  # Plugins
  advancedban = callPackage ./plugins/advancedban { };
  authme = callPackage ./plugins/authme { };
  authmebungee = callPackage ./plugins/authmebungee { };
  blockrename = callPackage ./plugins/blockrename { };
  chatty = callPackage ./plugins/chatty { };
  cleanmotd = callPackage ./plugins/cleanmotd { };
  coreprotect = callPackage ./plugins/coreprotect { };
  discordsrv = callPackage ./plugins/discordsrv { };
  elyby = callPackage ./plugins/elyby { };
  essentialsx = callPackage ./plugins/essentialsx { };
  essentialsx-antibuild = callPackage ./plugins/essentialsx/antibuild.nix { };
  essentialsx-chat = callPackage ./plugins/essentialsx/chat.nix { };
  essentialsx-discord = callPackage ./plugins/essentialsx/discord.nix { };
  essentialsx-geo = callPackage ./plugins/essentialsx/geo.nix { };
  essentialsx-protect = callPackage ./plugins/essentialsx/protect.nix { };
  essentialsx-spawn = callPackage ./plugins/essentialsx/spawn.nix { };
  essentialsx-xmpp = callPackage ./plugins/essentialsx/xmpp.nix { };
  illegalstack = callPackage ./plugins/illegalstack { };
  inventoryrollbackplus = callPackage ./plugins/inventoryrollbackplus { };
  itemcontrol = callPackage ./plugins/itemcontrol { };
  lightchatbubbles = callPackage ./plugins/lightchatbubbles { };
  luckperms = callPackage ./plugins/luckperms { };
  negativity = callPackage ./plugins/negativity { };
  placeholderapi = callPackage ./plugins/placeholderapi { };
  plasmovoice = callPackage ./plugins/plasmovoice { };
  playtime = callPackage ./plugins/playtime { };
  protocollib = callPackage ./plugins/protocollib { };
  redlib = callPackage ./plugins/redlib { };
  skinsrestorer = callPackage ./plugins/skinsrestorer { };
  tablist = callPackage ./plugins/tablist { };
  tablistbungee = callPackage ./plugins/tablistbungee { };
  tabtps = callPackage ./plugins/tabtps { };
  vault = callPackage ./plugins/vault { };
}
