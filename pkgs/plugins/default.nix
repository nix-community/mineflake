{ callPackage, ... }:

{
  coreprotect = callPackage ./coreprotect { };
  advancedban = callPackage ./advancedban { };
} // (callPackage ./shortbin.nix { })
