{ callPackage, ... }:

{
  advancedban = callPackage ./advancedban { };
  coreprotect = callPackage ./coreprotect { };
  cleanmotd = callPackage ./cleanmotd { };
} // (callPackage ./shortbin.nix { })
