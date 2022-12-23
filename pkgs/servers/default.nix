{ callPackage, ... }:

rec {
  waterfall_1-19-3 = callPackage ./waterfall { };
  waterfall = waterfall_1-19-3;
} // (callPackage ./shortbin.nix { })
