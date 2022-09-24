{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "DiscordSRV";
  version = "1.25.1";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmYCCMu5iuCUXbUJZXnUbC9BqLTW6rQEXU6ckQ5YqVMMUt";
    sha256 = "1ipcq3ap3xi3w3g1bhd5jzs7y00blfb2mph66g6hjskhq9n4ypms";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Discord bridging plugin for block game";
    homepage = "https://discordsrv.com/";
    license = licenses.gpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/DiscordSRV/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/DiscordSRV/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
      "plugins/DiscordSRV/alerts.yml" = {
        type = "yaml";
        data.Alerts = null;
      };
      "plugins/DiscordSRV/linking.yml" = {
        type = "yaml";
        data = importJSON ./linking.yml.json;
      };
      "plugins/DiscordSRV/synchronization.yml" = {
        type = "yaml";
        data = importJSON ./synchronization.yml.json;
      };
      "plugins/DiscordSRV/voice.yml" = {
        type = "yaml";
        data = importJSON ./voice.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/DiscordSRV" ];
  };
}
