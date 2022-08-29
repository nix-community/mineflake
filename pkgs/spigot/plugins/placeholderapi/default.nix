{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.11.2";
in
stdenv.mkDerivation {
  inherit version;

  pname = "PlaceholderAPI";

  src = fetchurl {
    url = "https://w3s.link/ipfs/bafybeigvumgag6nuirysu4kufwqpiiqavmrjlvtrkqkplszztasa733dua/PlaceholderAPI-${version}.jar";
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
    server = "spigot";
    type = "result";
    folders = [ "plugins/PlaceholderAPI" ];
  };
}
