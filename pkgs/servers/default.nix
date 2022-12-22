{ callPackage, ... }:

{
  waterfall = callPackage ./waterfall { };
} // (callPackage ./shortbin.nix { })
