{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "AdvancedBan";
  version = "2.3.0";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmdvDBpqbYrBRnJAYxoJ6Jekwn3kHBykPHhHQ1BiSy9Zte";
    sha256 = "1n0x0cwsci6zbn8ls0a3wp1770hlwwxn056cizi110camfnnajbv";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "AdvancedBan is a ban plugin for single servers and server networks with a great looking ban message";
    homepage = "https://github.com/DevLeoko/AdvancedBan";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/AdvancedBan/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/AdvancedBan/Layouts.yml" = {
        type = "yaml";
        data = importJSON ./Layouts.yml.json;
      };
      "plugins/AdvancedBan/Messages.yml" = {
        type = "yaml";
        data = importJSON ./Messages.yml.json;
      };
    };
    server = [ "spigot" "bungee" ];
    type = "result";
    folders = [ "plugins/AdvancedBan" "plugins/AdvancedBan/data" "plugins/AdvancedBan/logs" ];
  };
}
