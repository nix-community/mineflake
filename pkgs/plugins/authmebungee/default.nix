{ lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "AuthMeBungee";
  version = "2.2.0-beta1";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmdE4VwsMD8W45XqDjTKeEVnCnr9j2f7LNWwW8EDiAiHh8";
    sha256 = "0s530qkiqis4mwq5y5k99q556hvjc87mjzp5bdkjxdhxbfmks4by";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "A bridge between your AuthMe Spigot instance and your BungeeCord proxy";
    homepage = "https://github.com/AuthMe/AuthMeBungee";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    configs = {
      "plugins/AuthMeBungee/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "bungee" ];
    type = "result";
    deps = [ ];
    folders = [ "plugins/AuthMeBungee" ];
  };
}
