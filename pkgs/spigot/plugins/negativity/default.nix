{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.12.2";
in
stdenv.mkDerivation {
  inherit version;

  pname = "Negativity";

  src = fetchurl {
    url = "https://github.com/Elikill58/Negativity/releases/download/${version}/Negativity-${version}.jar";
    hash = "sha256-G0M84OaFQU2RI9ZkcJxqxch/tPMJ9M0TxqOsWvyinrI=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "A Minecraft AntiCheat for Spigot";
    homepage = "https://github.com/Elikill58/Negativity";
    # TODO: fill license
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/Negativity/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = "spigot";
    type = "result";
    folders = [ "plugins/Negativity" ];
  };
}
