{ callPackage, ... }:

{
  coreprotect = callPackage ./coreprotect {};
} // (callPackage ./shortbin.nix { })
