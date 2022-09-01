{ lib, stdenv, fetchurl, ... }:

let
  version = "0.2.7";
in
stdenv.mkDerivation {
  inherit version;

  pname = "CleanMotD";

  src = fetchurl {
    url = "https://github.com/2lstudios-mc/CleanMOTD/releases/download/c7f6459/CleanMoTD.jar";
    hash = "sha256-7ymUPUXJnOwBjI31y78SPLMnqiwPcyW1eiNDBtTqF3Y=";
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
    server = ["bungee"];
    type = "result";
    deps = [ ];
    folders = [ "plugins/CleanMotD" ];
  };
}
