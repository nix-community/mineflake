{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.2.9";
in
stdenv.mkDerivation {
  inherit version;

  pname = "TabListBungee";

  src = fetchurl {
    url = "https://github.com/montlikadani/TabList/releases/download/v${version}/TabList-bungee-${version}.jar";
    sha256 = "0220xj45yccxsqbxjvppl8b0r9l4j2hxw2bfz80xgykvzha6zhwf";
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
      "plugins/TabList/bungeeconfig.yml" = {
        type = "yaml";
        data = importJSON ./bungeeconfig.yml.json;
      };
    };
    server = [ "bungee" ];
    type = "result";
    folders = [ "plugins/" ];
  };
}
