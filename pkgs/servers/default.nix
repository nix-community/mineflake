{ callPackage, ... }:

rec {
  waterfall_1-19 = callPackage ./waterfall { };
  waterfall = waterfall_1-19;
} // (callPackage ./shortbin.nix { })
