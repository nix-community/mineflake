{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "PlayTime";
  version = "3.1.12";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmQEzJTD9SdSmrGDkw5Uf1Yrh8R9WdtjcnXAq7iBPUC3fT";
    sha256 = "053kv00g07pp083f18safwllgq9a41r69z2k806860r02p89mj1d";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Record time spent on minecraft server";
    homepage = "https://github.com/Wertik/PlayTime";
    license = licenses.gpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/PlayTime/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/PlayTime" ];
  };
}
