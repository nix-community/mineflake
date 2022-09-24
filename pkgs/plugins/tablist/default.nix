{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "TabList";
  version = "5.6.4";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmPkwNLM7R5MuqnvvNybmcCW2BQTov96WtcpW6Fgwtgexi";
    sha256 = "156vniw8mahh55g6b6682jjqgnr9zva1nhlsxan98sy7mhy5y3cp";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Animated tab";
    homepage = "https://github.com/montlikadani/TabList";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/TabList/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/TabList/tablist.yml" = {
        type = "yaml";
        data = importJSON ./tablist.yml.json;
      };
      "plugins/TabList/animcreator.yml" = {
        type = "yaml";
        data = importJSON ./animcreator.yml.json;
      };
      "plugins/TabList/groups.yml" = {
        type = "yaml";
        data = importJSON ./groups.yml.json;
      };
      "plugins/TabList/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/" ];
  };
}
