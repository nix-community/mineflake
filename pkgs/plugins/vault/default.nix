{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "Vault";
  version = "1.7.3";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmQ8Aczhs1HLFLcXcHzSo4cUhio9SebUgJUGj2UmaUt5ZL";
    sha256 = "07fhfz7ycdlbmxsri11z02ywkby54g6wi9q0myxzap1syjbyvdd6";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Abstraction Library for Bukkit";
    homepage = "https://github.com/MilkBowl/Vault";
    license = licenses.lgpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/Vault/config.yml" = {
        type = "yaml";
        data = {
          update-check = true;
        };
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/Vault" ];
  };
}
