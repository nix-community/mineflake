{ pkgs, ... }:

with pkgs; {
  # Utils
  utils = callPackage ../utils { };

  # Servers
  paper = callPackage ./servers/paper_1.18.2 { };
  paper_1_18_2 = callPackage ./servers/paper_1.18.2 { };

  # Plugins
  luckperms = callPackage ./plugins/luckperms { };
  coreprotect = callPackage ./plugins/coreprotect { };
  essentialsx = callPackage ./plugins/essentialsx { };
  essentialsx-antibuild = callPackage ./plugins/essentialsx/antibuild.nix { };
  essentialsx-chat = callPackage ./plugins/essentialsx/chat.nix { };
  essentialsx-discord = callPackage ./plugins/essentialsx/discord.nix { };
  essentialsx-geo = callPackage ./plugins/essentialsx/geo.nix { };
  essentialsx-protect = callPackage ./plugins/essentialsx/protect.nix { };
  essentialsx-spawn = callPackage ./plugins/essentialsx/spawn.nix { };
  essentialsx-xmpp = callPackage ./plugins/essentialsx/xmpp.nix { };
  redlib = callPackage ./plugins/redlib { };
  vault = callPackage ./plugins/vault { };
  authme = callPackage ./plugins/authme { };
  chatty = callPackage ./plugins/chatty { };
  negativity = callPackage ./plugins/negativity { };
  tabtps = callPackage ./plugins/tabtps { };
  protocollib = callPackage ./plugins/protocollib { };
  illegalstack = callPackage ./plugins/illegalstack { };
  playtime = callPackage ./plugins/playtime { };
  placeholderapi = callPackage ./plugins/placeholderapi { };
}
