{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "PlaceholderAPI";
  version = "2.11.2";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeigvumgag6nuirysu4kufwqpiiqavmrjlvtrkqkplszztasa733dua/PlaceholderAPI-2.11.2.jar";
    sha256 = "1mkp74qmxn0x58q5yw4xf2j9i9naamjsdk0x2cib52mzsw4cnx06";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "The best and simplest way to add placeholders to your server";
    homepage = "https://github.com/PlaceholderAPI/PlaceholderAPI";
    license = licenses.gpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/PlaceholderAPI/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/PlaceholderAPI" ];
  };
}
