{ lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "CleanMotD";
  version = "0.2.7";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmNZdN1me8E4Er4iT9EhQQAKSRysNeMaYcunyoRKcn1zgs";
    sha256 = "0xhpxba0chr3gasjawqg5jm2gcrw2azwpxcdih0yr7698lyr8agg";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Simple and light plugin to manage the motd of your server";
    homepage = "https://github.com/2lstudios-mc/CleanMOTD";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    configs = {
      "plugins/CleanMotD/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
      "plugins/CleanMotD/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "bungee" "spigot" ];
    type = "result";
    deps = [ ];
    folders = [ "plugins/CleanMotD" ];
  };
}
