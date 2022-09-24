{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "PlasmoVoice";
  version = "1.0.10";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmXXbPLkqp11xW27iv281MaksjE3HofXi2XKSSXEPV8kFV";
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
