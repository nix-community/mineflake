{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "LightChatBubbles";
  version = "4";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeihs6rrxe3mnx6gozhfpfevtsykarbr3gkzi2bwmoc2a2lymnbkp4m/LightChatBubbles.jar";
    sha256 = "1qld1n4rdd2fnyirjvgr04hkqkfka66qp9lh3hrk2bgw12d1mbpv";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Minecraft chat bubbles plugin";
    homepage = "https://gitlab.com/atesin/LightChatBubbles";
    license = licenses.gpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/LightChatBubbles/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/LightChatBubbles" ];
    legacy = true;
  };
}
