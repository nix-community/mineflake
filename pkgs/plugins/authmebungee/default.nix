{ lib, stdenv, fetchurl, ... }:

let
  version = "2.2.0-beta1";
in
stdenv.mkDerivation {
  inherit version;

  pname = "AuthMeBungee";

  src = fetchurl {
    url = "https://github.com/AuthMe/AuthMeBungee/releases/download/${version}/AuthMeBungee-${version}.jar";
    hash = "sha256-fhE9q1sdti5nW+V+WQ9ickNTCk5pFl8wr0RHHCcGo2g=";
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
