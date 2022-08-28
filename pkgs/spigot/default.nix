{ pkgs, ... }:

with pkgs; {
  # Utils
  utils = callPackage ../utils { };

  # Servers
  paper_1_18_2 = callPackage ./servers/paper_1.18.2 { };

  # Plugins
  luckperms = callPackage ./plugins/luckperms { };
  coreprotect = callPackage ./plugins/coreprotect { };
}
