{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "5.6.3";
in
stdenv.mkDerivation {
  inherit version;

  pname = "TabList";

  src = fetchurl {
    url = "https://github.com/montlikadani/TabList/releases/download/v${version}/TabList-bukkit-${version}.jar";
    sha256 = "1g7bnssfwv6c37chcyj91vyid3r59c5a4dlx7wlnj5095609hg5x";
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
