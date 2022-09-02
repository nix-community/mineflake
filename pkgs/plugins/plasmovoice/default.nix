{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.0.10";
in
stdenv.mkDerivation {
  inherit version;

  pname = "PlasmoVoice";

  src = fetchurl {
    url = "https://github.com/plasmoapp/plasmo-voice/releases/download/${version}-spigot/plasmovoice-server-${version}.jar";
    sha256 = "1pgja0mmjwgw0nhjz7dai8rmkqwa017c0jafnkyhpmnqykgm33yd";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Proximity voice сhat mod for Spigot Minecraft servers";
    homepage = "https://github.com/plasmoapp/plasmo-voice";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/PlasmoVoice/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/PlasmoVoice" ];
  };
}
