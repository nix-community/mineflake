{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "3.1.12";
in
stdenv.mkDerivation {
  inherit version;

  pname = "PlayTime";

  src = fetchurl {
    url = "https://github.com/Wertik/PlayTime/releases/download/${version}/PlayTime-${version}.jar";
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
    server = ["spigot"];
    type = "result";
    folders = [ "plugins/PlayTime" ];
  };
}
