{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "14.2.3";
in
stdenv.mkDerivation {
  inherit version;

  pname = "SkinsRestorer";

  src = fetchurl {
    url = "https://github.com/SkinsRestorer/SkinsRestorerX/releases/download/${version}/SkinsRestorer.jar";
    sha256 = "0rg9i29jly5jmsxd7wld9xxh3cvz7vk6bwk9cm8j75g0qzgp3534";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Restoring offline mode skins & changing skins for Bukkit/Spigot/paper, BungeeCord/Waterfall, Sponge, CatServer and Velocity servers";
    homepage = "https://github.com/SkinsRestorer/SkinsRestorerX";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/SkinsRestorer/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/SkinsRestorer/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
    };
    server = [ "spigot" "bungee" ];
    type = "result";
    folders = [ "plugins/SkinsRestorer" "plugins/SkinsRestorer/Players" "plugins/SkinsRestorer/Skins" ];
  };
}
