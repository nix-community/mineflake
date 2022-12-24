{ callPackage, ... }:

{
  coreprotect = callPackage ./coreprotect { };
  cleanmotd = callPackage ./cleanmotd { };
} // (callPackage ./shortbin.nix { })
