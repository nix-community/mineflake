{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "5.6.0-beta2";
in
stdenv.mkDerivation {
  inherit version;

  pname = "AuthMe";

  src = fetchurl {
    url = "https://github.com/AuthMe/AuthMeReloaded/releases/download/${version}/AuthMe-${version}.jar";
    hash = "sha256-v/O0FW5DKotFKlm2q9h4jYEhXyYiu2kbQ9gGaeUbI4Y=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Prevent username stealing on your server";
    homepage = "https://github.com/AuthMe/AuthMeReloaded";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/AuthMe/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = "spigot";
    type = "result";
    folders = [ "plugins/AuthMe" ];
  };
}
