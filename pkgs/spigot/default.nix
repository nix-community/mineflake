{ pkgs, ... }:

with pkgs; {
  # Utils
  utils = callPackage ../utils { };

  # Servers
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
}
