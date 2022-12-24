{ callPackage, ... }:

{
  advancedban = callPackage ./advancedban { };
  cleanmotd = callPackage ./cleanmotd { };
  coreprotect = callPackage ./coreprotect { };
  discordsrv = callPackage ./discordsrv { };
} // (callPackage ./shortbin.nix { })
